## File description:
## Plot Figure 7: Forecast Error Variance Decomposition

## Setup
rm(list = ls())
library(areaplot)
source("./code/config.R")
source("./code/utils/set_plot_palette.R")

## SET plotting parameters
mdls <- c("zerosign", "cholesky")   ## Which specifications to use
fig_sz <- c(4, 8 / 3)               ## Figure (width, height)
N <- 4                              ## Number of variables
cols <- c(lc_line2, lc_line3, lc_line4, lc_line7)
legs <- c("Inflow", "Outflow", "Level", "Length")

## Define function
plot_fevd <- function(mdl, in_dir, out_dir, vv, lc, leg, fig_size = c(4, 3)) {

    ## Read in FEVD
    fevd_name <- paste0(mdl, "_fevd_v", vv)
    filename <- paste0(in_dir, mdl, "/", fevd_name, ".csv")
    fevd <- read.csv(filename, header = FALSE, stringsAsFactors = FALSE)

    ## Plot FEVD
    pdf(paste0(out_dir, "/", mdl, "/", fevd_name, ".pdf"),
        width = fig_size[1], height = fig_size[2])
    par(mar = c(2.5, 2.5, 0.75, 0.5))
    par(mgp = c(1.5, 0.35, 0))
    leg_switch <- (vv == 1)
    areaplot(0:(nrow(fevd) - 1), 100 * fevd,
        xlim = c(0, 20), ylim = c(0, 100),
        xaxs = "i", yaxs = "i",
        xlab = "Quarters", ylab = "Percent",
        cex.lab = 1, cex.axis = 1,
        tck = -0.025,
        col = lc,
        legend = leg_switch,
        args.legend = list(
            x = 14, y = 96,
            legend = leg, bg = "white", bty = "c", cex = 0.9))
    dev.off()

}

## Plot FEVDs
for (mdl in mdls) {
    for (ii in 1:N) {
        plot_fevd(mdl, ores_dir, ofig_dir, ii, cols, legs, fig_size = fig_sz)
    }
}
