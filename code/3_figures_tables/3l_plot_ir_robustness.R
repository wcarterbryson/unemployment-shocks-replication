## File description:
## Plot robustness for IRFS

## Setup
rm(list = ls())
library(tis)
source("./code/config.R")
source("./code/utils/set_plot_palette.R")

## SET plotting parameters
robust <- c("lags", "sample", "specification")
mdl <- "zerosign"       ## Model name
fig_sz <- c(2, 2)       ## Figure (width, height)
line_width <- 2         ## Line width
line_color <- lc_line1  ## Line color
Nhp <- 20               ## Number of horizons to plot
adj <- 0.025            ## Ylim adjustment
N <- 4                  ## Number of variables/shocks

## Define plotting function
plot_ir_robust <- function(mdl, in_dir, out_dir,
    vv, ee, Nhp, lc, lw, lt = 1, fig_size = c(4, 3), yadj = 0.05) {

    ## Read in IRF
    irf_name <- paste0(mdl, "_ir_v", vv, "_e", ee)
    filename <- paste0(in_dir, "/", irf_name, ".csv")
    ir <- read.csv(filename, header = FALSE, stringsAsFactors = FALSE)
    h <- 0:(nrow(ir) - 1)

    ## Extract median and quantiles
    med  <- ir$V1
    low1 <- ir$V2
    upp1 <- ir$V3
    low2 <- ir$V4
    upp2 <- ir$V5

    ## Set ylims automatically
    ylims <- c(
        min(-0.01, (1 + yadj) * min(low2)), max(0.01, (1 + yadj) * max(upp2)))

    ## Create plot
    pdf(paste0(out_dir, "/", irf_name, ".pdf"),
        width = fig_size[1], height = fig_size[2])
    par(mar = c(2.5, 1.5, 0.5, 0.5))
    par(mgp = c(1.5, 0.35, 0))
    plot(h, med, type = "l",
        xlim = c(0, Nhp), ylim = ylims,
        xaxs = "i", xlab = "Quarters after shock", ylab = "",
        cex.lab = 1, cex.axis = 0.9, tck = -0.025,
        col = lc, lty = lt, lwd = lw)
    polygon(c(h, rev(h)), c(low2, rev(upp2)),
            col = "gray65", border = "gray65")
    polygon(c(h, rev(h)), c(low1, rev(upp1)),
            col = "gray45", border = "gray45")
    lines(h, med, col = lc_line1, lty = lt_line1, lwd = lw)
    lines(c(-1, Nhp + 1), c(0, 0), col = "black", lty = 3, lw = 1)
    box(lwd = 1)
    dev.off()

}

## Plot IRFs
for (rb in robust) {
    if (rb == "specification") {
        N <- 6
    }

    ## Define directories
    idir <- paste0(ores_dir, "robustness/", rb, "/")
    odir <- paste0(ofig_dir, "robustness/", rb, "/")

    for (ee in 1:N) {
        for (vv in 1:N) {
            plot_ir_robust(mdl, idir, odir, vv, ee, Nhp,
                line_color, line_width, fig_size = fig_sz, yadj = adj)
        }
    }
}
