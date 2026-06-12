## File description:
## Clean CPS three-state flows dataset

## Clear workspace and load libraries
rm(list = ls())
library(zoo)
library(seasonal)
library(lubridate)
library(data.table)

## Load functions and set paths
source("./code/config.R")
print("----- Constructing 3-state flows") ## Print progress to screen

## SET parameters
do_import <- TRUE       ## Flag to re-import raw data
samp_st <- "1978-01-01" ## Sample start
samp_ed <- "2024-12-31" ## Sample end

################################################################################
## 1. Import data ##############################################################
################################################################################

## Define function
cps_import <- function(proj_dir, data_dir, save_dir, keep_cols = "lfs",
                       ipums_r = "cps_extract.R", do_diag = TRUE) {

    ## Step 1: Import and clean IPUMS data
    ## NOTE: Default sample = {!NIU, age 16+, has validated longitudinal id}
    print("----- Importing raw data -----")
    start_time <- Sys.time()                    ## Start the timer
    setwd(data_dir)                             ## Change to data directory
    source(ipums_r)                             ## Run IPUMS file
    setwd(proj_dir)                             ## Change back main directory
    bms_raw <- as.data.table(data)              ## Copy to local data.table
    rm("data", envir = .GlobalEnv); gc()        ## Free global data
    colnames(bms_raw) <- tolower(colnames(bms_raw))
    cps_clean <- subset(bms_raw, !(labforce == 0) & age >= 16 & cpsidv != 0)
    rm(bms_raw); gc()                           ## Free full table before merge

    ## Create labor force status and date variable
    cps_clean$month <- as.Date(
        paste(cps_clean$year, cps_clean$month, 1, sep = "-"))
    cps_clean$lfs <- "." ## Labor force status
    cps_clean$lfs[cps_clean$empstat >= 10 & cps_clean$empstat <= 19] <- "E"
    cps_clean$lfs[cps_clean$empstat >= 20 & cps_clean$empstat <= 29] <- "U"
    cps_clean$lfs[cps_clean$empstat >= 30 & cps_clean$empstat <= 39] <- "N"

    ## Step 2: Merge adjacent months
    ## Keep only the month t observations
    cps_t0 <- cps_clean[cps_clean$mish %in% c(1, 2, 3, 5, 6, 7), ]
    cps_t0 <- subset(
        cps_t0, select = c("cpsidv", "month", "lnkfw1mwt", keep_cols))
    names(cps_t0)[names(cps_t0) %in% keep_cols] <- paste0(
        names(cps_t0)[names(cps_t0) %in% keep_cols], "_0")

    ## Keep only the month t + 1 observations
    cps_t1 <- cps_clean[cps_clean$mish %in% c(2, 3, 4, 6, 7, 8), ]
    cps_t1 <- subset(
        cps_t1, select =  c("cpsidv", "month", keep_cols))
    names(cps_t1)[names(cps_t1) %in% keep_cols] <- paste0(
        names(cps_t1)[names(cps_t1) %in% keep_cols], "_1")
    cps_t1$month <- add_with_rollback(cps_t1$month, months(-1))

    ## Merge months t and t + 1
    ## NOTE: assumes missing-at-random
    rm(cps_clean); gc()                         ## Free before merge
    setDT(cps_t0); setDT(cps_t1)
    setkeyv(cps_t0, c("cpsidv", "month")); setkeyv(cps_t1, c("cpsidv", "month"))
    cps_merged <- merge(cps_t0, cps_t1, by = c("cpsidv", "month"), all = FALSE)

    ## Export match diagnostics
    if (do_diag) {
        tmp <- data.table(cps_merged)
        tmp$N <- 1
        tmp <- tmp[, .(avg_wt = mean(lnkfw1mwt, na.rm = TRUE),
                    sum_wt = sum(lnkfw1mwt, na.rm = TRUE),
                    nobs = sum(N)), by = .(month)]
        tmp <- data.frame(tmp)
        all_months <- data.frame(
            month = seq(min(tmp$month), max(tmp$month), by = "month"))
        tmp <- merge(all_months, tmp, by = "month", all.x = TRUE)
        tmp <- tmp[order(tmp$month), ]
        write.csv(tmp, file = paste0(dcln_dir, "match_diagnostics.csv"),
                  row.names = FALSE)
    }

    ## Step 3: Collapse grossflows
    cps_merged$AB <- paste0(cps_merged$lfs_0, cps_merged$lfs_1)

    ## Collapse by (month, grossflows) and reshape wide
    gf <- cps_merged[, .(
        grossflows = sum(lnkfw1mwt, na.rm = TRUE)), by = .(month, AB)]
    gf <- gf[order(gf$AB, gf$month), ]
    gf <- reshape(gf, idvar = "month", timevar = "AB", direction = "wide")

    ## Fill in missing months
    allmonths <- data.frame(
        month = seq(min(gf$month), max(gf$month), by = "month"))
    gf <- merge(allmonths, gf, by = "month", all.x = TRUE)
    gf <- gf[order(gf$month), ]

    ## Clean up and export
    cps_grossflows_raw <- gf
    colnames(cps_grossflows_raw) <- gsub(
        "\\.", "_", colnames(cps_grossflows_raw))
    cps_grossflows_raw[cps_grossflows_raw == 0] <- NA
    save(cps_grossflows_raw,
         file = paste0(save_dir, "cps_grossflows_raw.RData"))

    ## End timer
    end_time <- Sys.time()
    execution_time <- end_time - start_time
    print(execution_time)

}

## Call function
if (do_import) {
    cps_import(mast_path, dcps_dir, dcln_dir)
}

################################################################################
## 2. Adjust data ##############################################################
################################################################################

## Define function: seasonal adjustment (using X-13)
## NOTE: Takes grossflows as input and automatically converts to proportions
cps_adjust_sa <- function(cps) {

    ## Get labels for all grossflows series
    all_flows <- sub(
        ".*_(.*)", "\\1", colnames(cps)[grep("grossflows", colnames(cps))])

    ## Convert to proportions
    cps$P <- rowSums(cps[, -1], na.rm = TRUE)
    cps[cps$P < 1e8, -1] <- NA # Replace with NA if < 100mil
    cps[, paste0("pi_", all_flows)] <- cps[, paste0(
        "grossflows_", all_flows)] / cps$P

    ## Loop over all flows
    for (flow in all_flows) {

        ## Extract proportion series as ts() object
        temp <- ts(cps[, paste0("pi_", flow)], frequency = 12,
                   start = c(year(min(cps$month)), month(min(cps$month))))

        ## Adjust series
        temp_filled <- na.locf(temp, na.rm = FALSE)     ## Fill NAs: LOCF
        temp_sa <- as.numeric(final(seas(temp_filled))) ## Seasonally adjust
        cps[, paste0("pi_", flow, "_sa")] <- temp_sa    ## Save

    }

    ## Re-normalize proportions by adjusted population
    pi_ser <- paste0("pi_", all_flows, "_sa")
    cps$P_sa <- rowSums(cps[, grep("*_sa", names(cps), value = TRUE)])
    cps[, pi_ser] <- cps[, pi_ser] / cps$P_sa
    cps$P_sa <- NULL

    ## Extract adjusted stocks
    cps$stocks_E_sa <- rowSums(
        cps[, grep("pi_E.*_sa", names(cps), value = TRUE)])
    cps$stocks_U_sa <- rowSums(
        cps[, grep("pi_U.*_sa", names(cps), value = TRUE)])
    cps$stocks_N_sa <- rowSums(
        cps[, grep("pi_N.*_sa", names(cps), value = TRUE)])

    ## Compute adjusted probabilities
    cps$EE_sa <- cps$pi_EE_sa / cps$stocks_E_sa
    cps$EU_sa <- cps$pi_EU_sa / cps$stocks_E_sa
    cps$EN_sa <- cps$pi_EN_sa / cps$stocks_E_sa
    cps$UE_sa <- cps$pi_UE_sa / cps$stocks_U_sa
    cps$UU_sa <- cps$pi_UU_sa / cps$stocks_U_sa
    cps$UN_sa <- cps$pi_UN_sa / cps$stocks_U_sa
    cps$NE_sa <- cps$pi_NE_sa / cps$stocks_N_sa
    cps$NU_sa <- cps$pi_NU_sa / cps$stocks_N_sa
    cps$NN_sa <- cps$pi_NN_sa / cps$stocks_N_sa

    ## Keep seasonally adjusted series
    cps_sa <- cps[, c("month", grep("*_sa", names(cps), value = TRUE))]
    names(cps_sa) <- gsub("_sa", "", names(cps_sa))

    ## Return
    return(cps_sa)

}

## Define function: time aggregation adjustment
## NOTE: Takes probabilities as input
cps_adjust_ta <- function(cps) {

    ## Recover diagonal states
    cps$EE <- 1 - cps$EU - cps$EN
    cps$UU <- 1 - cps$UE - cps$UN
    cps$NN <- 1 - cps$NE - cps$NU

    ## Rearrange columns into Markov transition matrix (excluding "M" state)
    flows <- subset(cps, select = c(EE, EU, EN,
                                    UE, UU, UN,
                                    NE, NU, NN))

    ## Loop over time periods
    TT <- nrow(flows)   ## Get number of time periods
    flows_adj <- matrix(NA, TT, 9)  ## Preallocate
    for (iit in 1:TT) {

        ## Extract time period and reshape to matrix
        tempt <- flows[iit, ]
        tempmatt <- matrix(unlist(tempt), nrow = 3)

        ## Construct markov transition matrix
        nt <- tempmatt / colSums(tempmatt)

        ## Skip if NA
        if (!any(is.na(nt))) {

            ## Eigenvalues and eigenvectors
            mut <- eigen(nt)$values
            pt <- eigen(nt)$vectors

            ## mu_tilde_t = diagonal matrix of log(mu_t)
            tmut <- diag(log(mut))

            ## lambda_t
            lamt <- pt %*% tmut %*% solve(pt)

            ## Lambda_t
            Lamt <- 1 - exp(-lamt)

            ## Replace diagonals
            AA <- Lamt - diag(diag(Lamt))
            Lamt <- diag(1 - colSums(AA)) + AA

            ## Store
            flows_adj[iit, ] <- as.vector(Lamt)

        }

    }

    ## Convert to data frame
    flows_adj <- as.data.frame(flows_adj)
    cps_adj <- cbind(cps$month, flows_adj)
    colnames(cps_adj) <- c("month", colnames(flows))

    ## Return
    return(cps_adj)

}

## Define function: roll forward stocks using perpetual inventory method
## NOTE: Takes probabilities as input
cps_stocks_pim <- function(flows) {

    ## Check to make sure data.frame includes only flow probabilities
    flows <- flows[, !grepl("pi_*", names(flows))]
    flows <- flows[, !grepl("stocks_*", names(flows))]
    if (ncol(flows) > 10) {
        error("Please only input flow probabilities")
    }

    ## Get stationary distribution of flow probabilities
    PP_hat <- colMeans(flows[, -1], na.rm = TRUE) # Take time average
    PP_hat <- t(matrix(unlist(PP_hat), nrow = 3))
    PP_bar <- PP_hat
    for (i in 2:1000) {
        PP_bar <- PP_bar %*% PP_hat 
    }

    ## Loop over time periods
    stocks_ta <- data.frame(matrix(NA, nrow(flows), 3)) # Preallocate
    stocks_ta[1, ] <- PP_bar[1, ] # Initialize at steady state distribution
    for (iit in 2:nrow(stocks_ta)) {

        ## Get transition matrix at (t - 1)
        PP <- t(matrix(unlist(flows_3state_adj[iit - 1, -1]), nrow = 3))

        ## Carry last observation forward if missing
        if (any(is.na(PP))) {
            stocks_ta[iit, ] <- stocks_ta[iit - 1, ]
        } else {
            stocks_ta[iit, ] <- t(PP) %*% t(stocks_ta[iit - 1, ])
        }

    }

    ## Set stocks
    flows$stocks_E <- stocks_ta[, 1]
    flows$stocks_U <- stocks_ta[, 2]
    flows$stocks_N <- stocks_ta[, 3]

    ## Recover proportions
    flows$pi_EE <- flows$stocks_E * flows$EE
    flows$pi_EU <- flows$stocks_E * flows$EU
    flows$pi_EN <- flows$stocks_E * flows$EN
    flows$pi_UU <- flows$stocks_U * flows$UU
    flows$pi_UE <- flows$stocks_U * flows$UE
    flows$pi_UN <- flows$stocks_U * flows$UN
    flows$pi_NN <- flows$stocks_N * flows$NN
    flows$pi_NE <- flows$stocks_N * flows$NE
    flows$pi_NU <- flows$stocks_N * flows$NU

    ## Re-normalize proportions
    pi_ser <- grep("pi_", names(flows), value = TRUE)
    flows[pi_ser] <- flows[pi_ser] / rowSums(flows[pi_ser])

    ## Return
    return(flows)

}

## Load data and select sample
load(paste0(dcln_dir, "cps_grossflows_raw.RData"))
cps <- cps_grossflows_raw ## Unpack
cps <- cps[(cps$month >= ymd(samp_st)) & (cps$month <= ymd(samp_ed)), ]

## Call functions to adjust
print("----- Adjusting data -----")
flows_3state_unadj <- cps_adjust_sa(cps)
flows_3state_adj <- cps_adjust_ta(flows_3state_unadj)
flows_3state_adj <- cps_stocks_pim(flows_3state_adj)

## Sort columns: same order for adjusted and unadjusted
flows_cols <- grep("pi_", names(flows_3state_adj), value = TRUE)
stock_cols <- grep("stocks_", names(flows_3state_adj), value = TRUE)
new_order <- c("month", flows_cols, stock_cols)
other_cols <- setdiff(names(flows_3state_adj), new_order)
flows_3state_unadj <- flows_3state_unadj[, c(new_order, other_cols)]
flows_3state_adj <- flows_3state_adj[, c(new_order, other_cols)]

## Export
save(flows_3state_unadj, file = paste0(dcln_dir, "flows_3state_unadj.RData"))
save(flows_3state_adj, file = paste0(dcln_dir, "flows_3state_adj.RData"))
