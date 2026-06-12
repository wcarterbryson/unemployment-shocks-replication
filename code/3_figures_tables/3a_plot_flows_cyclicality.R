## File description:
## Plot Figure 1: Cyclical Properties of Worker Flows

## Setup
rm(list = ls())
library(tis)
library(mFilter)
library(lubridate)
library(data.table)
source("./code/config.R")
source("./code/utils/set_plot_palette.R")

## SET plotting parameters
series <- c("pi_EU", "pi_UE", "EU", "UE") ## Series to use
plot_st <- 1978
zeroline_tis <- tis(0, start = 1970, end = 2030, tif = "monthly")
leg <- c("EU", "UE")
lc <- c(lc_line2, lc_line1)
lt <- c(lt_line2, lt_line1)
lw <- 3
samp_ed <- c(2019, 4)

################################################################################
## Import and clean data #######################################################
################################################################################

## Load data and extract only EU and UE series
load(paste0(dcln_dir, "flows_3state_adj.RData"))
flows_clean <- subset(flows_3state_adj, select = c("month", series))

## Convert to quarterly
flows_clean$q <- quarter(flows_clean$month)
flows_clean$yyyy <- year(flows_clean$month)
flows_clean <- data.table(flows_clean)
flows_clean <- flows_clean[, lapply(.SD, mean), by = .(yyyy, q)]
flows_clean <- data.frame(flows_clean)
flows_clean <- subset(flows_clean, yyyy <= samp_ed[1] & q <= samp_ed[2]) # Trim

## Apply Hamilton and HP filters
for (ser in series) {
    flows_clean[, paste0(ser, "_ham")] <- 100 * (log(flows_clean[, ser]) - log(
        ham_filter(flows_clean[, ser], 8, 4)$trend))
    flows_clean[, paste0(ser, "_hpf")] <- 100 * (log(flows_clean[, ser]) - log(
        hpfilter(flows_clean[, ser], freq = 1600)$trend))
}

## Convert to tis: grossflows
grossflows_ham_tis <- tis(subset(flows_clean, select = c(pi_EU_ham, pi_UE_ham)),
                          start = c(flows_clean$yyyy[1], flows_clean$q[1]),
                          tif = "quarterly")
grossflows_hpf_tis <- tis(subset(flows_clean, select = c(pi_EU_hpf, pi_UE_hpf)),
                          start = c(flows_clean$yyyy[1], flows_clean$q[1]),
                          tif = "quarterly")

## Convert to tis: flows
flows_ham_tis <- tis(subset(flows_clean, select = c(EU_ham, UE_ham)),
                     start = c(flows_clean$yyyy[1], flows_clean$q[1]),
                     tif = "quarterly")
flows_hpf_tis <- tis(subset(flows_clean, select = c(EU_hpf, UE_hpf)),
                     start = c(flows_clean$yyyy[1], flows_clean$q[1]),
                     tif = "quarterly")

################################################################################
## Plot ########################################################################
################################################################################

## Plot: grossflows (ham)
pdf(paste0(ofig_dir, "grossflows_cyclicality_ham.pdf"), width = 4, height = 3)
tisPlot(grossflows_ham_tis, nberShade = TRUE,
        color = lc, lineWidth = lw, lineType = lt,
        leftTopLabel = "Percent Deviation from Trend", tck = 0.015, xSpace = 0,
        labelRightTicks = FALSE, labelLeftTicks = TRUE,
        xTickFreq = "Annual", xTickSkip = 3, midPoints = FALSE,
        xAxisMin = ti(plot_st, tif = "annual"),
        leftAxisMin = -50, rightAxisMin = -50,
        leftAxisMax = 40, rightAxisMax = 40,
        leftMargin = 2, rightMargin = 0.25, topMargin = 1.25, bottomMargin = 1)
lines(zeroline_tis, col = lc_zerol, lty = lt_zerol, lwd = lw_zerol)
tisLegend(legend = leg, col = lc, lwd = lw, lty = lt,
          xrel = 0.75, yrel = 0.00, cex = 0.9, text.col = "black")
dev.off()

## Plot: grossflows (hpf)
pdf(paste0(ofig_dir, "grossflows_cyclicality_hpf.pdf"), width = 4, height = 3)
tisPlot(grossflows_hpf_tis, nberShade = TRUE,
        color = lc, lineWidth = lw, lineType = lt,
        leftTopLabel = "Percent Deviation from Trend", tck = 0.015, xSpace = 0,
        labelRightTicks = FALSE, labelLeftTicks = TRUE,
        xTickFreq = "Annual", xTickSkip = 3, midPoints = FALSE,
        xAxisMin = ti(plot_st, tif = "annual"),
        leftAxisMin = -50, rightAxisMin = -50,
        leftAxisMax = 40, rightAxisMax = 40,
        leftMargin = 2, rightMargin = 0.25, topMargin = 1.25, bottomMargin = 1)
lines(zeroline_tis, col = lc_zerol, lty = lt_zerol, lwd = lw_zerol)
tisLegend(legend = leg, col = lc, lwd = lw, lty = lt,
          xrel = 0.75, yrel = 0.00, cex = 0.9, text.col = "black")
dev.off()

## Plot: flows (ham)
pdf(paste0(ofig_dir, "flows_cyclicality_ham.pdf"), width = 4, height = 3)
tisPlot(flows_ham_tis, nberShade = TRUE,
        color = lc, lineWidth = lw, lineType = lt,
        leftTopLabel = "Percent Deviation from Trend", tck = 0.015, xSpace = 0,
        labelRightTicks = FALSE, labelLeftTicks = TRUE,
        xTickFreq = "Annual", xTickSkip = 3, midPoints = FALSE,
        xAxisMin = ti(plot_st, tif = "annual"),
        leftAxisMin = -50, rightAxisMin = -50,
        leftAxisMax = 40, rightAxisMax = 40,
        leftMargin = 2, rightMargin = 0.25, topMargin = 1.25, bottomMargin = 1)
lines(zeroline_tis, col = lc_zerol, lty = lt_zerol, lwd = lw_zerol)
tisLegend(legend = leg, col = lc, lwd = lw, lty = lt,
          xrel = 0.75, yrel = 0.00, cex = 0.9, text.col = "black")
dev.off()

## Plot: flows (hpf)
pdf(paste0(ofig_dir, "flows_cyclicality_hpf.pdf"), width = 4, height = 3)
tisPlot(flows_hpf_tis, nberShade = TRUE,
        color = lc, lineWidth = lw, lineType = lt,
        leftTopLabel = "Percent Deviation from Trend", tck = 0.015, xSpace = 0,
        labelRightTicks = FALSE, labelLeftTicks = TRUE,
        xTickFreq = "Annual", xTickSkip = 3, midPoints = FALSE,
        xAxisMin = ti(plot_st, tif = "annual"),
        leftAxisMin = -50, rightAxisMin = -50,
        leftAxisMax = 40, rightAxisMax = 40,
        leftMargin = 2, rightMargin = 0.25, topMargin = 1.25, bottomMargin = 1)
lines(zeroline_tis, col = lc_zerol, lty = lt_zerol, lwd = lw_zerol)
tisLegend(legend = leg, col = lc, lwd = lw, lty = lt,
          xrel = 0.75, yrel = 0.00, cex = 0.9, text.col = "black")
dev.off()
