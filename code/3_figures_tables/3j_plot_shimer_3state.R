## File description:
## Plot Figure A.2: Transition Probabilities in the 3-State Model

## Setup
rm(list = ls())
library(tis)
library(lubridate)
library(data.table)
source("./code/config.R")
source("./code/utils/set_plot_palette.R")

## SET plotting parameters
flow_list <- c("UE", "EU", "NE", "EN", "NU", "UN")
plot_st <- 1978
leg <- c("Raw", "Time-aggregation adjusted", "Shimer (2012)")
lc <- c(lc_line3, lc_line1, lc_line2)
lt <- c(lt_line3, lt_line1, lt_line2)
lw <- 3
lr_sp <- 0.75
ud_sp <- 1.00
samp_ed <- c(2024, 4) ## End of sample

################################################################################
## Import and clean data #######################################################
################################################################################

## Load data and convert to quarterly (unadj)
load(paste0(dcln_dir, "flows_3state_unadj.RData"))
qdata_unadj <- subset(flows_3state_unadj, select = c("month", flow_list))
colnames(qdata_unadj)[-1] <- paste0(colnames(qdata_unadj)[-1], "_unj")
qdata_unadj$q <- quarter(qdata_unadj$month)
qdata_unadj$yyyy <- year(qdata_unadj$month)
qdata_unadj <- data.table(subset(qdata_unadj, select = -c(month)))
qdata_unadj <- qdata_unadj[, lapply(.SD, mean), by = .(yyyy, q)]
qdata_unadj <- data.frame(qdata_unadj)

## Load data and convert to quarterly (adj)
load(paste0(dcln_dir, "flows_3state_adj.RData"))
qdata_adj <- subset(flows_3state_adj, select = c("month", flow_list))
colnames(qdata_adj)[-1] <- paste0(colnames(qdata_adj)[-1], "_adj")
qdata_adj$q <- quarter(qdata_adj$month)
qdata_adj$yyyy <- year(qdata_adj$month)
qdata_adj <- data.table(subset(qdata_adj, select = -c(month)))
qdata_adj <- qdata_adj[, lapply(.SD, mean), by = .(yyyy, q)]
qdata_adj <- data.frame(qdata_adj)

## Load data and convert quarterly dates (Shimer)
load(paste0(dcln_dir, "flows_shimer.RData"))
flows_shimer$q <- quarter(flows_shimer$quarter)
flows_shimer$yyyy <- year(flows_shimer$quarter)
flows_shimer <- subset(flows_shimer, select = c("yyyy", "q", flow_list))

## Merge together the three samples
qdata <- merge(qdata_unadj, qdata_adj, by = c("yyyy", "q"), all.x = TRUE)
qdata <- merge(qdata, flows_shimer, by = c("yyyy", "q"), all.x = TRUE)
qdata <- subset(qdata, qdata$yyyy <= samp_ed[1] & qdata$q <= samp_ed[2])

## Convert to tis
for (ab in flow_list) {
    temp <- tis(qdata[, grepl(ab, names(qdata))],
                start = c(qdata$yyyy[1], qdata$q[1]), tif = "quarterly")
    assign(paste0(ab, "_tis"), temp) ## Assign to new variable
}

################################################################################
## Plot ########################################################################
################################################################################

## Plot
pdf(paste0(ofig_dir, "shimer_3state.pdf"), width = 6, height = 8)
par(mfrow = c(3, 2))

## Panel: UE
tisPlot(100 * UE_tis, nberShade = TRUE,
        head = c("U-to-E"), headCex = 1.2,
        color = lc, lineWidth = lw, lineType = lt,
        leftTopLabel = "Percent", tck = 0.015, xSpace = 0,
        labelRightTicks = FALSE, labelLeftTicks = TRUE,
        xTickFreq = "Annual", xTickSkip = 3, midPoints = FALSE,
        xAxisMin = ti(plot_st, tif = "annual"),
        xCex = 1.75, yCex = 1.75,
        leftMargin = 1.85, rightMargin = 0.5 + lr_sp,
        topMargin = 1.5, bottomMargin = 1.5 + ud_sp)

## Panel: EU
tisPlot(100 * EU_tis, nberShade = TRUE,
        head = c("E-to-U"), headCex = 1.2,
        color = lc, lineWidth = lw, lineType = lt,
        leftTopLabel = "Percent", tck = 0.015, xSpace = 0,
        labelRightTicks = FALSE, labelLeftTicks = TRUE,
        xTickFreq = "Annual", xTickSkip = 3, midPoints = FALSE,
        xAxisMin = ti(plot_st, tif = "annual"),
        xCex = 1.75, yCex = 1.75,
        leftMargin = 1.85 + lr_sp, rightMargin = 0.5,
        topMargin = 1.5, bottomMargin = 1.5 + ud_sp)
tisLegend(legend = leg, col = lc, lwd = lw, lty = lt,
          xrel = 0.075, yrel = 0.00, cex = 1.5, text.col = "black")

## Panel: NE
tisPlot(100 * NE_tis, nberShade = TRUE,
        head = c("N-to-E"), headCex = 1.2,
        color = lc, lineWidth = lw, lineType = lt,
        leftTopLabel = "Percent", tck = 0.015, xSpace = 0,
        labelRightTicks = FALSE, labelLeftTicks = TRUE,
        xTickFreq = "Annual", xTickSkip = 3, midPoints = FALSE,
        xAxisMin = ti(plot_st, tif = "annual"),
        xCex = 1.75, yCex = 1.75,
        leftMargin = 1.85, rightMargin = 0.5 + lr_sp,
        topMargin = 1.5, bottomMargin = 1.5 + ud_sp)

## Panel: EN
tisPlot(100 * EN_tis, nberShade = TRUE,
        head = c("E-to-N"), headCex = 1.2,
        color = lc, lineWidth = lw, lineType = lt,
        leftTopLabel = "Percent", tck = 0.015, xSpace = 0,
        labelRightTicks = FALSE, labelLeftTicks = TRUE,
        xTickFreq = "Annual", xTickSkip = 3, midPoints = FALSE,
        xAxisMin = ti(plot_st, tif = "annual"),
        xCex = 1.75, yCex = 1.75,
        leftAxisMin = 1.9, rightAxisMin = 1.9,
        leftMargin = 1.85 + lr_sp, rightMargin = 0.5,
        topMargin = 1.5, bottomMargin = 1.5 + ud_sp)

## Panel: NU
tisPlot(100 * NU_tis, nberShade = TRUE,
        head = c("N-to-U"), headCex = 1.2,
        color = lc, lineWidth = lw, lineType = lt,
        leftTopLabel = "Percent", tck = 0.015, xSpace = 0,
        labelRightTicks = FALSE, labelLeftTicks = TRUE,
        xTickFreq = "Annual", xTickSkip = 3, midPoints = FALSE,
        xAxisMin = ti(plot_st, tif = "annual"),
        xCex = 1.75, yCex = 1.75,
        leftMargin = 1.85, rightMargin = 0.5 + lr_sp,
        topMargin = 1.5, bottomMargin = 1.5 + ud_sp)

## Panel: UN
tisPlot(100 * UN_tis, nberShade = TRUE,
        head = c("U-to-N"), headCex = 1.2,
        color = lc, lineWidth = lw, lineType = lt,
        leftTopLabel = "Percent", tck = 0.015, xSpace = 0,
        labelRightTicks = FALSE, labelLeftTicks = TRUE,
        xTickFreq = "Annual", xTickSkip = 3, midPoints = FALSE,
        xAxisMin = ti(plot_st, tif = "annual"),
        xCex = 1.75, yCex = 1.75,
        leftMargin = 1.85 + lr_sp, rightMargin = 0.5,
        topMargin = 1.5, bottomMargin = 1.5 + ud_sp)

dev.off()
