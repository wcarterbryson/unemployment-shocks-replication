## File description:
## Plot Figure A.2: Transition Probabilities in the 3-State Model

## Setup
rm(list = ls())
library(tis)
library(mFilter)
library(lubridate)
library(data.table)
source("./code/config.R")
source("./code/utils/set_plot_palette.R")

## SET plotting parameters
flow_list <- c("UE", "EU")
plot_st <- 1978
leg <- c("2-state", "3-state", "3-state (adjusted)")
lc <- c(lc_line1, lc_line2, lc_line3)
lt <- c(lt_line1, lt_line2, lt_line3)
lw <- 3
fw <- 4
fh <- 3
samp_ed <- c(2019, 4) ## End of sample

################################################################################
## Import and clean data #######################################################
################################################################################

## Load data and convert to quarterly (3-state, unadj)
load(paste0(dcln_dir, "flows_3state_unadj.RData"))
qdata_unadj <- subset(flows_3state_unadj, select = c("month", flow_list))
colnames(qdata_unadj)[-1] <- paste0(colnames(qdata_unadj)[-1], "_unj")
qdata_unadj$q <- quarter(qdata_unadj$month)
qdata_unadj$yyyy <- year(qdata_unadj$month)
qdata_unadj <- data.table(subset(qdata_unadj, select = -c(month)))
qdata_unadj <- qdata_unadj[, lapply(.SD, mean), by = .(yyyy, q)]
qdata_unadj <- data.frame(qdata_unadj)

## Load data and convert to quarterly (3-state, adj)
load(paste0(dcln_dir, "flows_3state_adj.RData"))
qdata_adj <- subset(flows_3state_adj, select = c("month", flow_list))
colnames(qdata_adj)[-1] <- paste0(colnames(qdata_adj)[-1], "_adj")
qdata_adj$q <- quarter(qdata_adj$month)
qdata_adj$yyyy <- year(qdata_adj$month)
qdata_adj <- data.table(subset(qdata_adj, select = -c(month)))
qdata_adj <- qdata_adj[, lapply(.SD, mean), by = .(yyyy, q)]
qdata_adj <- data.frame(qdata_adj)

## Load data and convert to quarterly (2-state)
load(paste0(dcln_dir, "flows_2state.RData"))
qdata_2state <- subset(flows_2state, select = c("month", flow_list))
qdata_2state$q <- quarter(qdata_2state$month)
qdata_2state$yyyy <- year(qdata_2state$month)
qdata_2state <- data.table(subset(qdata_2state, select = -c(month)))
qdata_2state <- qdata_2state[, lapply(.SD, mean), by = .(yyyy, q)]
qdata_2state <- data.frame(qdata_2state)

## Merge together the three samples
qdata <- merge(qdata_2state, qdata_unadj,by = c("yyyy", "q"), all.x = TRUE)
qdata <- merge(qdata, qdata_adj, by = c("yyyy", "q"), all.x = TRUE)
qdata <- subset(qdata, yyyy >= 1978)
qdata <- subset(qdata, qdata$yyyy <= samp_ed[1] & qdata$q <= samp_ed[2])

## Apply Hamilton and HP filters
series <- c("", "_unj", "_adj")
for (flw in flow_list) {
    for (ser in series) {
        fs <- paste0(flw, ser)
        qdata[, paste0(fs, "_ham")] <- 100 * (log(qdata[, fs]) - log(
            ham_filter(qdata[, fs], 8, 4)$trend))
        qdata[, paste0(fs, "_hpf")] <- 100 * (log(qdata[, fs]) - log(
            hpfilter(qdata[, fs], freq = 1600)$trend))
    }
}

## Convert to tis
UE_hpf_tis <- tis(subset(qdata, select = c(UE_hpf, UE_unj_hpf, UE_adj_hpf)),
                  start = c(qdata$yyyy[1], qdata$q[1]), tif = "quarterly")
EU_hpf_tis <- tis(subset(qdata, select = c(EU_hpf, EU_unj_hpf, EU_adj_hpf)),
                  start = c(qdata$yyyy[1], qdata$q[1]), tif = "quarterly")
UE_ham_tis <- tis(subset(qdata, select = c(UE_ham, UE_unj_ham, UE_adj_ham)),
                  start = c(qdata$yyyy[1], qdata$q[1]), tif = "quarterly")
EU_ham_tis <- tis(subset(qdata, select = c(EU_ham, EU_unj_ham, EU_adj_ham)),
                  start = c(qdata$yyyy[1], qdata$q[1]), tif = "quarterly")

################################################################################
## Plot ########################################################################
################################################################################

## Plot: UE (hpf)
pdf(paste0(ofig_dir, "2state_vs_3state_hpf_ue.pdf"), width = fw, height = fh)
tisPlot(UE_hpf_tis, nberShade = TRUE,
        color = lc, lineWidth = lw, lineType = lt,
        leftTopLabel = "Percent Deviation from Trend", tck = 0.015, xSpace = 0,
        labelRightTicks = FALSE, labelLeftTicks = TRUE,
        xTickFreq = "Annual", xTickSkip = 4, midPoints = FALSE,
        xAxisMin = ti(plot_st, tif = "annual"),
        leftAxisMin = -32, rightAxisMin = -32,
        leftAxisMax = 30, rightAxisMax = 30,
        leftMargin = 2, rightMargin = 0.25, topMargin = 1, bottomMargin = 1)
tisLegend(legend = leg, col = lc, lwd = lw, lty = lt,
          xrel = 0.025, yrel = -0.015, cex = 0.75, text.col = "black")
dev.off()

## Plot: EU (hpf)
pdf(paste0(ofig_dir, "2state_vs_3state_hpf_eu.pdf"), width = fw, height = fh)
tisPlot(EU_hpf_tis, nberShade = TRUE,
        color = lc, lineWidth = lw, lineType = lt,
        leftTopLabel = "Percent Deviation from Trend", tck = 0.015, xSpace = 0,
        labelRightTicks = FALSE, labelLeftTicks = TRUE,
        xTickFreq = "Annual", xTickSkip = 4, midPoints = FALSE,
        xAxisMin = ti(plot_st, tif = "annual"),
        leftAxisMin = -32, rightAxisMin = -32,
        leftAxisMax = 30, rightAxisMax = 30,
        leftMargin = 2, rightMargin = 0.25, topMargin = 1, bottomMargin = 1)
tisLegend(legend = leg, col = lc, lwd = lw, lty = lt,
          xrel = 0.025, yrel = -0.015, cex = 0.75, text.col = "black")
dev.off()

## Plot: UE (ham)
pdf(paste0(ofig_dir, "2state_vs_3state_ham_ue.pdf"), width = fw, height = fh)
tisPlot(UE_ham_tis, nberShade = TRUE,
        color = lc, lineWidth = lw, lineType = lt,
        leftTopLabel = "Percent Deviation from Trend", tck = 0.015, xSpace = 0,
        labelRightTicks = FALSE, labelLeftTicks = TRUE,
        xTickFreq = "Annual", xTickSkip = 4, midPoints = FALSE,
        xAxisMin = ti(plot_st, tif = "annual"),
        leftAxisMin = -75, rightAxisMin = -75,
        leftAxisMax = 50, rightAxisMax = 50,
        leftMargin = 2, rightMargin = 0.25, topMargin = 1, bottomMargin = 1)
tisLegend(legend = leg, col = lc, lwd = lw, lty = lt,
          xrel = 0.025, yrel = 0.75, cex = 0.75, text.col = "black")
dev.off()

## Plot: EU (ham)
pdf(paste0(ofig_dir, "2state_vs_3state_ham_eu.pdf"), width = fw, height = fh)
tisPlot(EU_ham_tis, nberShade = TRUE,
        color = lc, lineWidth = lw, lineType = lt,
        leftTopLabel = "Percent Deviation from Trend", tck = 0.015, xSpace = 0,
        labelRightTicks = FALSE, labelLeftTicks = TRUE,
        xTickFreq = "Annual", xTickSkip = 4, midPoints = FALSE,
        xAxisMin = ti(plot_st, tif = "annual"),
        leftAxisMin = -75, rightAxisMin = -75,
        leftAxisMax = 50, rightAxisMax = 50,
        leftMargin = 2, rightMargin = 0.25, topMargin = 1, bottomMargin = 1)
tisLegend(legend = leg, col = lc, lwd = lw, lty = lt,
          xrel = 0.025, yrel = 0.75, cex = 0.75, text.col = "black")
dev.off()
