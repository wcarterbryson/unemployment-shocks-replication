## File description:
## Make Table 1 and 2: Granger causality

## Setup
rm(list = ls())
library(tis)
library(mFilter)
library(lubridate)
library(data.table)
source("./code/utils/utility_functions.R")
source("./code/utils/set_paths.R")
source("./code/utils/set_plot_palette.R")

## SET plotting parameters
series <- c("pi_EU", "pi_UE", "EU", "UE")   ## Series to use
jlags <- -1:-4                              ## Lags to consider
sig_level <- 0.01                           ## Significance level (alpha)
samp_ed <- c(2019, 4)                       ## End of sample

################################################################################
## Import and clean data #######################################################
################################################################################

## Load data
load(paste0(dcln_dir, "flows_3state_unadj.RData"))
mdata <- subset(flows_3state_unadj, select = c("month", series))

## Take quarterly averages
mdata$yyyy <- year(mdata$month)
mdata$mq <- (quarter(mdata$month) - 1) * 3 + 1
mdata$quarter <- make_date(mdata$yyyy, mdata$mq, 1)
mdata[, c("month", "yyyy", "mq")] <- NULL
mdata <- data.table(mdata)
qdata <- mdata[, lapply(.SD, mean, na.rm = TRUE), by = .(quarter)]

## Convert to quarterly rates
qdata$EU <- 100 * (1 - (1 - qdata$EU)^3)
qdata$UE <- 100 * (1 - (1 - qdata$UE)^3)
qdata <- data.frame(qdata)
qdata <- subset(qdata,
    year(qdata$quarter) <= samp_ed[1] & quarter(qdata$quarter) <= samp_ed[2])

## Apply Hamilton and HP filters
for (ser in series) {
    qdata[, paste0(ser, "_ham")] <- 100 * log(
        qdata[, ser] / ham_filter(qdata[, ser], 8, 4)$trend)
    qdata[, paste0(ser, "_hpf")] <- 100 * log(
        qdata[, ser] / hpfilter(qdata[, ser], freq = 1600)$trend)
}

################################################################################
## Create leads/lags and trim sample ###########################################
################################################################################

## Loop over series and measures
for (s in series) {
    for (m in c("_ham", "_hpf", "")) {
        temp <- qdata[, paste0(s, m)] ## Extract
        for (j in jlags) {
            if (j < 0) {
                qdata[, paste0(s, m, "_l", -j)] <- lag_vector(temp, -j) # Lags
            }
            if (j > 0) {
                qdata[, paste0(s, m, "_f", j)] <- lag_vector(temp, -j) # Leads
            }
        }
    }
}

## Remove NaNs
qdata_clean <- qdata[rowSums(is.na(qdata)) == 0, ]

################################################################################
## Test: EU --> UE #############################################################
################################################################################

## Preallocate
gran_eu_ue_raw <- matrix(NA, 5, length(jlags))
gran_eu_ue_ham <- matrix(NA, 5, length(jlags))
gran_eu_ue_hpf <- matrix(NA, 5, length(jlags))

## Loop
for (iil in seq_along(jlags)) {

    ## EU --> UE: raw
    temp_eu_ue_raw <- my_granger_clean("pi_UE ~ pi_EU",
        dat = qdata_clean, alph = sig_level, p = -jlags[iil])
    gran_eu_ue_raw[1, iil] <- temp_eu_ue_raw$S1
    gran_eu_ue_raw[2, iil] <- temp_eu_ue_raw$c
    gran_eu_ue_raw[3, iil] <- temp_eu_ue_raw$pval
    gran_eu_ue_raw[4, iil] <- temp_eu_ue_raw$h
    gran_eu_ue_raw[5, iil] <- temp_eu_ue_raw$BIC1

    ## EU --> UE: ham
    temp_eu_ue_ham <- my_granger_clean("pi_UE_ham ~ pi_EU_ham",
        dat = qdata_clean, alph = sig_level, p = -jlags[iil])
    gran_eu_ue_ham[1, iil] <- temp_eu_ue_ham$S1
    gran_eu_ue_ham[2, iil] <- temp_eu_ue_ham$c
    gran_eu_ue_ham[3, iil] <- temp_eu_ue_ham$pval
    gran_eu_ue_ham[4, iil] <- temp_eu_ue_ham$h
    gran_eu_ue_ham[5, iil] <- temp_eu_ue_ham$BIC1

    ## EU --> UE: hpf
    temp_eu_ue_hpf <- my_granger_clean("pi_UE_hpf ~ pi_EU_hpf",
        dat = qdata_clean, alph = sig_level, p = -jlags[iil])
    gran_eu_ue_hpf[1, iil] <- temp_eu_ue_hpf$S1
    gran_eu_ue_hpf[2, iil] <- temp_eu_ue_hpf$c
    gran_eu_ue_hpf[3, iil] <- temp_eu_ue_hpf$pval
    gran_eu_ue_hpf[4, iil] <- temp_eu_ue_hpf$h
    gran_eu_ue_hpf[5, iil] <- temp_eu_ue_hpf$BIC1

}

## Round
out_eu_ue_raw <- round(gran_eu_ue_raw, 2)
out_eu_ue_ham <- round(gran_eu_ue_ham, 2)

## Format
out_eu_ue_raw <- format(out_eu_ue_raw, digits = 3, scientific = FALSE)
out_eu_ue_ham <- format(out_eu_ue_ham, digits = 3, scientific = FALSE)
out_eu_ue <- cbind(out_eu_ue_raw, "", out_eu_ue_ham)

## Reject?
out_eu_ue[4, ] <- gsub("1.00", "\\\\multicolumn{1}{c}{Y}", out_eu_ue[4, ])
out_eu_ue[4, ] <- gsub("0.00", "\\\\multicolumn{1}{c}{N}", out_eu_ue[4, ])

## Row names
rownames(out_eu_ue) <- c("$S_1$", "Crit. Val.", "$p$-value", "Reject?", "BIC")

## Output
write.table(out_eu_ue,
            file = paste0(otab_dir, "granger_table_eu_ue.tex"),
            row.names = TRUE, col.names = FALSE,
            sep = " & ", eol = "\\\\ \n", quote = FALSE)

################################################################################
## Test: UE --> EU #############################################################
################################################################################

## Preallocate
gran_ue_eu_raw <- matrix(NA, 5, length(jlags))
gran_ue_eu_ham <- matrix(NA, 5, length(jlags))
gran_ue_eu_hpf <- matrix(NA, 5, length(jlags))

## Loop
for (iil in seq_along(jlags)) {

    ## UE --> EU: raw
    temp_ue_eu_raw <- my_granger_clean("pi_EU ~ pi_UE",
        dat = qdata_clean, alph = sig_level, p = -jlags[iil])
    gran_ue_eu_raw[1, iil] <- temp_ue_eu_raw$S1
    gran_ue_eu_raw[2, iil] <- temp_ue_eu_raw$c
    gran_ue_eu_raw[3, iil] <- temp_ue_eu_raw$pval
    gran_ue_eu_raw[4, iil] <- temp_ue_eu_raw$h
    gran_ue_eu_raw[5, iil] <- temp_ue_eu_raw$BIC1

    ## UE --> EU: ham
    temp_ue_eu_ham <- my_granger_clean("pi_EU_ham ~ pi_UE_ham",
        dat = qdata_clean, alph = sig_level, p = -jlags[iil])
    gran_ue_eu_ham[1, iil] <- temp_ue_eu_ham$S1
    gran_ue_eu_ham[2, iil] <- temp_ue_eu_ham$c
    gran_ue_eu_ham[3, iil] <- temp_ue_eu_ham$pval
    gran_ue_eu_ham[4, iil] <- temp_ue_eu_ham$h
    gran_ue_eu_ham[5, iil] <- temp_ue_eu_ham$BIC1

    ## UE --> EU: hpf
    temp_ue_eu_hpf <- my_granger_clean("pi_EU_hpf ~ pi_UE_hpf",
        dat = qdata_clean, alph = sig_level, p = -jlags[iil])
    gran_ue_eu_hpf[1, iil] <- temp_ue_eu_hpf$S1
    gran_ue_eu_hpf[2, iil] <- temp_ue_eu_hpf$c
    gran_ue_eu_hpf[3, iil] <- temp_ue_eu_hpf$pval
    gran_ue_eu_hpf[4, iil] <- temp_ue_eu_hpf$h
    gran_ue_eu_hpf[5, iil] <- temp_ue_eu_hpf$BIC1

}

## Round
out_ue_eu_raw <- round(gran_ue_eu_raw, 2)
out_ue_eu_ham <- round(gran_ue_eu_ham, 2)

## Format
out_ue_eu_raw <- format(out_ue_eu_raw, digits = 3, scientific = FALSE)
out_ue_eu_ham <- format(out_ue_eu_ham, digits = 3, scientific = FALSE)
out_ue_eu <- cbind(out_ue_eu_raw, "", out_ue_eu_ham)

## Reject?
out_ue_eu[4, ] <- gsub("1.00", "\\\\multicolumn{1}{c}{Y}", out_ue_eu[4, ])
out_ue_eu[4, ] <- gsub("0.00", "\\\\multicolumn{1}{c}{N}", out_ue_eu[4, ])

## Row names
rownames(out_ue_eu) <- c("$S_1$", "Crit. Val.", "$p$-value", "Reject?", "BIC")

## Output
write.table(out_ue_eu,
            file = paste0(otab_dir, "granger_table_ue_eu.tex"),
            row.names = TRUE, col.names = FALSE,
            sep = " & ", eol = "\\\\ \n", quote = FALSE)
