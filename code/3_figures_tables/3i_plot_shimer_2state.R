## File description:
## Plot Figure A.1: Transition Probabilities in the 2-State Model

## Setup
rm(list = ls())
library(tis)
library(lubridate)
library(data.table)
source("./code/utils/utility_functions.R")
source("./code/utils/set_paths.R")
source("./code/utils/set_plot_palette.R")

## SET plotting parameters
leg <- c("Replicated", "Shimer (2012)")
lc <- c(lc_line1, lc_line2)
lt <- c(lt_line1, lt_line2)
lw <- 3
d94 <- 1994 ## Date of 1994 redesign
fw <- 4
fh <- 3
samp_ed <- c(2024, 4) ## End of sample

################################################################################
## Import and clean data #######################################################
################################################################################

## Load data
load(paste0(dcln_dir, "flows_2state.RData"))
load(paste0(dcln_dir, "flows_shimer.RData"))
qdata <- flows_2state

## Convert quarterly dates
qdata$q <- quarter(qdata$month)
qdata$yyyy <- year(qdata$month)
qdata <- subset(qdata, select = -c(month))
flows_shimer$q <- quarter(flows_shimer$quarter)
flows_shimer$yyyy <- year(flows_shimer$quarter)
flows_shimer <- subset(flows_shimer, select = c(yyyy, q, Ft, Xt))

## Convert to quarterly
qdata <- data.table(qdata)
qdata <- qdata[, lapply(.SD, mean), by = .(yyyy, q)]
qdata <- data.frame(qdata)
qdata <- subset(qdata, qdata$yyyy <= samp_ed[1] & qdata$q <= samp_ed[2])

## Merge
qdata <- merge(qdata, flows_shimer, by = c("yyyy", "q"), all.x = TRUE)

## Convert to tis
Ft_tis <- tis(subset(qdata, select = c(UE, Ft)),
              start = c(qdata$yyyy[1], qdata$q[1]), tif = "quarterly")
Ft_adj_tis <- tis(subset(qdata, select = c(UE_adj, Ft)),
                  start = c(qdata$yyyy[1], qdata$q[1]), tif = "quarterly")
Xt_tis <- tis(subset(qdata, select = c(EU, Xt)),
              start = c(qdata$yyyy[1], qdata$q[1]), tif = "quarterly")
Xt_adj_tis <- tis(subset(qdata, select = c(EU_adj, Xt)),
                  start = c(qdata$yyyy[1], qdata$q[1]), tif = "quarterly")

################################################################################
## Plot ########################################################################
################################################################################

## Plot: employment exit probability
pdf(paste0(ofig_dir, "shimer_2state_emp_exit.pdf"), width = fw, height = fh)
tisPlot(100 * Xt_tis, nberShade = TRUE,
        color = lc, lineWidth = lw, lineType = lt,
        leftTopLabel = "Percent", tck = 0.015, xSpace = 0,
        labelRightTicks = FALSE, labelLeftTicks = TRUE,
        xTickFreq = "Annual", xTickSkip = 4, midPoints = FALSE,
        leftAxisMax = 6, rightAxisMax = 6, leftAxisMin = 1, rightAxisMin= 1,
        leftMargin = 1.5, rightMargin = 0.5, topMargin = 1, bottomMargin = 1.25)
lines(c(d94, d94), c(-100, 100), col = "navy", lty = 2)
text(d94 + 1.5, 6, labels = "1994 CPS Redesign",
     srt = 90, adj = 1, cex = 0.6, col = "navy")
tisLegend(legend = rev(leg), col = rev(lc), lwd = rev(lw), lty = rev(lt),
          xrel = 0.00, yrel = -0.03, cex = 0.8, text.col = "black")
dev.off()

## Plot: employment exit probability (adj)
pdf(paste0(ofig_dir, "shimer_2state_emp_exit_adj.pdf"), width = fw, height = fh)
tisPlot(100 * Xt_adj_tis, nberShade = TRUE,
        color = lc, lineWidth = lw, lineType = lt,
        leftTopLabel = "Percent", tck = 0.015, xSpace = 0,
        labelRightTicks = FALSE, labelLeftTicks = TRUE,
        xTickFreq = "Annual", xTickSkip = 4, midPoints = FALSE,
        leftAxisMax = 6, rightAxisMax = 6, leftAxisMin = 1, rightAxisMin = 1,
        leftMargin = 1.5, rightMargin = 0.5, topMargin = 1, bottomMargin = 1.25)
lines(c(d94, d94), c(-100, 100), col = "navy", lty = 2)
text(d94 + 1.5, 6, labels = "1994 CPS Redesign",
     srt = 90, adj = 1, cex = 0.6, col = "navy")
tisLegend(legend = rev(leg), col = rev(lc), lwd = rev(lw), lty = rev(lt),
          xrel = 0.00, yrel = -0.03, cex = 0.8, text.col = "black")
dev.off()

## Plot: job finding probability
pdf(paste0(ofig_dir, "shimer_2state_job_find.pdf"), width = fw, height = fh)
tisPlot(100 * Ft_tis, nberShade = TRUE,
        color = lc, lineWidth = lw, lineType = lt,
        leftTopLabel = "Percent", tck = 0.015, xSpace = 0,
        labelRightTicks = FALSE, labelLeftTicks = TRUE,
        xTickFreq = "Annual", xTickSkip = 4, midPoints = FALSE,
        leftAxisMax = 80, rightAxisMax = 80,
        leftAxisMin = 10, rightAxisMin = 10,
        leftMargin = 1.5, rightMargin = 0.5, topMargin = 1, bottomMargin = 1.25)
lines(c(d94, d94), c(-100, 100), col = "navy", lty = 2)
text(d94 + 1.5, 80, labels = "1994 CPS Redesign",
     srt = 90, adj = 1, cex = 0.6, col = "navy")
tisLegend(legend = rev(leg), col = rev(lc), lwd = rev(lw), lty = rev(lt),
          xrel = 0.00, yrel = -0.03, cex = 0.8, text.col = "black")
dev.off()

## Plot: job finding probability
pdf(paste0(ofig_dir, "shimer_2state_job_find_adj.pdf"), width = fw, height = fh)
tisPlot(100 * Ft_adj_tis, nberShade = TRUE,
        color = lc, lineWidth = lw, lineType = lt,
        leftTopLabel = "Percent", tck = 0.015, xSpace = 0,
        labelRightTicks = FALSE, labelLeftTicks = TRUE,
        xTickFreq = "Annual", xTickSkip = 4, midPoints = FALSE,
        leftAxisMax = 80, rightAxisMax = 80,
        leftAxisMin = 10, rightAxisMin = 10,
        leftMargin = 1.5, rightMargin = 0.5, topMargin = 1, bottomMargin = 1.25)
lines(c(d94, d94), c(-100, 100), col = "navy", lty = 2)
text(d94 + 1.5, 80, labels = "1994 CPS Redesign",
     srt = 90, adj = 1, cex = 0.6, col = "navy")
tisLegend(legend = rev(leg), col = rev(lc), lwd = rev(lw), lty = rev(lt),
          xrel = 0.00, yrel = -0.03, cex = 0.8, text.col = "black")
dev.off()
