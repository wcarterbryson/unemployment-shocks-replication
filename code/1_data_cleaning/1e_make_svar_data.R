## File description:
## Compile quarterly data and export for SVAR analysis

## Clear workspace and load libraries
rm(list = ls())
library(openxlsx)
library(lubridate)
library(data.table)

## Load functions and set paths
source("./code/config.R")

################################################################################
## Load data ###################################################################
################################################################################

## Load data
load(paste0(dcln_dir, "flows_2state.RData"))
load(paste0(dcln_dir, "flows_3state_adj.RData"))
load(paste0(dcln_dir, "fred_data_m.RData"))
load(paste0(dcln_dir, "fred_data_q.RData"))

## Format data (2-state)
flows_2state <- subset(flows_2state, select = c(month, EU_adj, UE_adj))
colnames(flows_2state) <- gsub("_adj", "_2state", colnames(flows_2state))
colnames(flows_2state) <- tolower(colnames(flows_2state))

## Format data (3-state)
flows_3state <- subset(flows_3state_adj, select = c(month, pi_EU, pi_UE))
colnames(flows_3state)[-1] <- paste0(colnames(flows_3state)[-1], "_3state")
colnames(flows_3state) <- tolower(colnames(flows_3state))

## Format data (FRED)
fred_m <- subset(fred_data_m, select = c(month, unrate, uempmean))
colnames(fred_m)[-1] <- c("ur", "mu")

## Clean Barnichon HWI data
hwi <- read.xlsx(paste0(draw_dir, "Barnichon/CompositeHWI.xlsx"), startRow = 8)
hwi$yyyy <- floor(hwi$year + 1e-10)
hwi$mm <- round((hwi$year - hwi$yyyy) * 12) + 1
hwi$month <- make_date(year = hwi$yyyy, month = hwi$mm, day = 1)
hwi <- subset(hwi, select = c(month, V_hwi))
colnames(hwi)[-1] <- "v"

################################################################################
## Clean data ##################################################################
################################################################################

## Merge into master data.frame at monthly level
mth_data <- merge(flows_2state, fred_m, by = "month", all.x = TRUE)
mth_data <- merge(mth_data, flows_3state, by = "month", all.x = TRUE)
mth_data <- merge(mth_data, hwi, by = "month", all.x = TRUE)

## Take quarterly averages
mth_data$yyyy <- year(mth_data$month)
mth_data$mq <- (quarter(mth_data$month) - 1) * 3 + 1
mth_data$quarter <- make_date(mth_data$yyyy, mth_data$mq, 1)
mth_data[, c("month", "yyyy", "mq")] <- NULL
mth_data <- data.table(mth_data)
qtr_data <- mth_data[, lapply(.SD, mean, na.rm = TRUE), by = .(quarter)]

## Convert to quarterly rates
qtr_data$eu_2state <- 100 * (1 - (1 - qtr_data$eu_2state)^3)
qtr_data$ue_2state <- 100 * (1 - (1 - qtr_data$ue_2state)^3)

# Merge GDP
qtr_data <- merge(qtr_data, fred_data_q, by = "quarter", all.x = TRUE)

## Export
svar_data <- data.frame(qtr_data)
save(svar_data, file = paste0(dcln_dir, "svar_data.RData"))
write.csv(svar_data, paste0(dcln_dir, "svar_data.csv"), row.names = FALSE)
