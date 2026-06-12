## File description:
## Clean two-state flows dataset

## Clear workspace and load libraries
rm(list = ls())
library(plyr)
library(seasonal)
library(lubridate)
library(data.table)

## Load functions and set paths
source("./code/config.R")
print("----- Constructing 2-state flows") ## Print progress to screen

## SET parameters
samp_ed <- "2024-12-31" ## Sample end

################################################################################
## 1. Clean CPS data ###########################################################
################################################################################

## Define function: get share of short-term unemployed from CPS
clean_cps <- function(proj_dir, datt_dir, save_dir, ipums_r = "cps_extract.R") {

    ## Bring in data
    setwd(datt_dir)
    source(ipums_r)
    setwd(proj_dir)
    colnames(data) <- tolower(colnames(data))   ## Convert to lowercase
    cps <- data.frame(data)                     ## Unpack

    ## Select sample
    cps <- subset(cps, labforce == 2 & (empstat >= 20 & empstat < 30)) ## U
    cps <- subset(cps, mish == 1 | mish == 5)   ## Incoming rotation groups
    cps <- subset(cps, age >= 16)               ## Age 16+ years old

    ## Compute counts of unemployed and unemployed | duration < 5 weeks
    cps$unemp <- 1
    cps$unemp_s <- 0
    cps$unemp_s[cps$durunemp < 5] <- 1

    ## Compute weighted counts
    cps$unemp_wt <- cps$unemp * cps$wtfinl
    cps$unemp_s_wt <- cps$unemp_s * cps$wtfinl

    ## Collapse to monthly (weighted)
    cps_t <- data.table(cps)
    cps_t <- cps_t[, .(unemp = sum(unemp_wt, na.rm = TRUE),
                       unemp_s = sum(unemp_s_wt, na.rm = TRUE)),
                   by = "year,month"]
    cps_t <- data.frame(cps_t)

    ## Compute shares
    cps_t$share_stu <- cps_t$unemp_s / cps_t$unemp

    ## Seasonally adjust data
    cps_t <- subset(cps_t, year >= 1994 & year <= 2019)
    temp <- ts(cps_t$share_stu, deltat = 1 / 12,
               start = c(cps_t$year[1], cps_t$month[1]))
    temp_sa <- seas(temp, na.action = na.x13, outlier = NULL)
    cps_t$share_stu_sa <- as.numeric(final(temp_sa))

    ## Create month dates
    cps_t$month_date <- ymd(paste(cps_t$year, cps_t$month, 1, sep = "-"))
    cps_t$month <- NULL
    cps_t$month <- cps_t$month_date

    ## Select certain columns: person-weighted, seasonally adjusted
    cps_share_stu <- subset(cps_t, select = c(month, share_stu_sa))
    colnames(cps_share_stu)[-1] <- "share_stu"

    ## Save as .RData file
    save(cps_share_stu, file = paste0(save_dir, "cps_share_stu.RData"))

}

## Call function
clean_cps(mast_path, dcps_dir, dcln_dir)

################################################################################
## 2. Clean BLS data ###########################################################
################################################################################

## Define function: get stocks from BLS LFS data
clean_bls <- function(proj_dir, datt_dir, save_dir) {

    ## Read in data
    bls_raw <- read.csv(
        paste0(datt_dir, "bls_lfs_stocks_raw.txt"), stringsAsFactors = FALSE)
    colnames(bls_raw) <- tolower(colnames(bls_raw))
    bls_clean <- bls_raw    ## Unpack

    ## Map values: measure
    bls_clean$meas <- mapvalues(bls_clean$series.id,
        from = c("LNS13008396", "LNS12000000", "LNS13000000"),
        to   = c("unemp_s", "emp", "unemp"))
    bls_clean$series.id <- NULL

    ## Reshape long
    bls_clean <- reshape(
        bls_clean, idvar = c("meas"), timevar = "date",
        varying = list(names(bls_clean)[-c(ncol(bls_clean))]),
        times = colnames(bls_clean)[grep("\\.", colnames(bls_clean))],
        v.names = "tot", direction = "long")
    rownames(bls_clean) <- NULL

    ## Reshape LFS measure wide
    bls_clean <- reshape(bls_clean, idvar = "date", timevar = "meas")

    ## Remove "tot." in colnames
    colnames(bls_clean) <- gsub("tot.", "", colnames(bls_clean))

    ## Reformat month-year codes
    bls_clean$month.name <- substr(bls_clean$date, 1, 3)
    bls_clean$month <- mapvalues(bls_clean$month.name,
        from = c("jan", "feb", "mar", "apr", "may", "jun",
                 "jul", "aug", "sep", "oct", "nov", "dec"),
        to   = c("1", "2", "3", "4", "5", "6",
                 "7", "8", "9", "10", "11", "12"))
    bls_clean$mm <- as.numeric(bls_clean$month)
    bls_clean$yyyy <- as.numeric(substr(bls_clean$date, 5, 8))
    bls_clean$month <- ymd(paste(bls_clean$yyyy, bls_clean$mm, 1, sep = "-"))

    ## Deal with strings in data
    bls_clean$emp <- gsub("\\(1\\)", "", bls_clean$emp)
    bls_clean$unemp <- gsub("\\(1\\)", "", bls_clean$unemp)
    bls_clean$unemp_s <- gsub("\\(1\\)", "", bls_clean$unemp_s)

    ## As numeric
    bls_clean$emp <- as.numeric(bls_clean$emp)
    bls_clean$unemp <- as.numeric(bls_clean$unemp)
    bls_clean$unemp_s <- as.numeric(bls_clean$unemp_s)

    ## Select columns
    bls_stocks <- subset(bls_clean, select = c(month, emp, unemp, unemp_s))

    ## Save as .RData file
    save(bls_stocks, file = paste0(save_dir, "bls_stocks.RData"))

}

## Call function
clean_bls(mast_path, dbls_dir, dcln_dir)

################################################################################
## 3. Construct 2-state flows (Shimer, 2012) ###################################
################################################################################

## Define Shimer Equation (5): U(t+1) - RHS
eq_5 <- function(xt, ut1, ft, lt, ut) {
    rhs <- (((1 - exp(-ft - xt)) * xt) / (ft + xt)) * lt + exp(-ft - xt) * ut
    dd <- ut1 - rhs
    return(dd)
}

## Define function: calculate job-finding and employment-exit probabilities
shimer_2state <- function(ut, ut1, ust1, et) {

    ## Define additional variables
    lt <- et + ut                   ## Size of the labor force
    Ft <- 1 - ((ut1 - ust1) / ut)   ## Job-finding probability (discrete)
    ft <- -log(1 - Ft)              ## Job-finding rate (continuous)

    ## Solve for employment-exit
    fx <- function(x) eq_5(x, ut1, ft, lt, ut)
    xroot <- uniroot(fx, -c(-10, 10))   ## Find root
    xt <- xroot$root                    ## Employment-exit rate
    Xt <- 1 - exp(-xt)                  ## Employment-exit probability

    ## Return
    return(list(job_finding = Ft, employment_exit = Xt))

}

## Define function: Construct 2-state flow probabilities
get_2state <- function(stocks, adj = FALSE) {

    ## Preallocate output data.frame
    TT <- nrow(stocks)
    flows_2state <- matrix(NA, TT, 2)

    ## Loop over time periods
    for (iit in 1:(TT - 1)) {

        ## Extract series: stocks
        ut  <- stocks$unemp[iit]        # U(t)
        ut1 <- stocks$unemp[iit + 1]    # U(t+1)
        et  <- stocks$emp[iit]          # E(t)

        ## Extract series: short-term unemployment (adjusted/unadjusted)
        if (adj) {
            ust1 <- stocks$unemp_s_adj[iit + 1]
        } else {
            ust1 <- stocks$unemp_s[iit + 1]
        }

        ## Calculate probabilities
        temp <- shimer_2state(ut, ut1, ust1, et)
        flows_2state[iit, 1] <- temp$job_finding
        flows_2state[iit, 2] <- temp$employment_exit

    }

    ## Return data.frame
    return(flows_2state)

}

## Load data
load(paste0(dcln_dir, "bls_stocks.RData"))
load(paste0(dcln_dir, "cps_share_stu.RData"))

## Create adjusted short-term unemployment series
bls_stocks <- merge(bls_stocks, cps_share_stu, by = "month", all.x = TRUE)
na_mask <- is.na(bls_stocks$share_stu)
bls_stocks$unemp_s_adj <- bls_stocks$unemp * bls_stocks$share_stu
bls_stocks$unemp_s_adj[na_mask] <- bls_stocks$unemp_s[na_mask]
bls_stocks$share_stu <- NULL    ## Remove adjustment series when done

## Create 2-state flow probabilities
flows_temp <- get_2state(bls_stocks, adj = FALSE)
flows_temp_adj <- get_2state(bls_stocks, adj = TRUE)

## Create data frame
flows_2state <- as.data.frame(cbind(flows_temp, flows_temp_adj))
flows_2state <- cbind(bls_stocks$month, flows_2state)
colnames(flows_2state) <- c("month", "UE", "EU", "UE_adj", "EU_adj")

## Export
flows_2state <- subset(flows_2state, month <= ymd(samp_ed))
save(flows_2state, file = paste0(dcln_dir, "flows_2state.RData"))
