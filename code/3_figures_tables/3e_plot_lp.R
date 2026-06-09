## File description:
## Plot Figure 5 and 6: local projections

## Setup
rm(list = ls())
source("./code/utils/utility_functions.R")
source("./code/utils/set_paths.R")
source("./code/utils/set_plot_palette.R")

## SET plotting parameters
mdls <- c("zerosign", "cholesky")   ## Which specifications to use
fig_sz <- c(8 / 3, 2.5)             ## Figure (width, height)
line_width <- 2                     ## Line width
line_color <- lc_line1              ## Line color
Nhp <- 20                           ## Number of horizons to plot
adj <- 0.025                        ## Ylim adjustment
N <- 4                              ## Number of shocks
Nx <- 3                             ## Number of LP variables

## Define plotting function
plot_lp <- function(mdl, in_dir, out_dir,
    xx, ee, Nhp, lc, lw, lt = 1, fig_size = c(4, 3), yadj = 0.05) {

    ## Read in IRF
    lp_name <- paste0(mdl, "_lp_x", xx, "_e", ee)
    filename <- paste0(in_dir, mdl, "/", lp_name, ".csv")
    lp <- read.csv(filename, header = FALSE, stringsAsFactors = FALSE)
    h <- 0:(nrow(lp) - 1)

    ## Extract median and confidence bands
    med <- 100 * lp$V1
    low <- 100 * lp$V2
    upp <- 100 * lp$V3

    ## Set ylims automatically
    ylims <- c(
        min(-0.01, (1 + yadj) * min(low)), max(0.01, (1 + yadj) * max(upp)))

    ## Create plot
    pdf(paste0(out_dir, "/", mdl, "/", lp_name, ".pdf"),
        width = fig_size[1], height = fig_size[2])
    par(mar = c(2.5, 1.5, 0.5, 0.5))
    par(mgp = c(1.5, 0.35, 0))
    plot(h, med, type = "l",
        xlim = c(0, Nhp), ylim = ylims,
        xaxs = "i",
        xlab = "Quarters after shock", ylab = "",
        cex.lab = 0.95, cex.axis = 0.95,
        tck = -0.025,
        col = lc, lty = lt, lwd = lw)
    polygon(c(h, rev(h)), c(low, rev(upp)),
            col = "gray65", border = "gray65")
    lines(h, med, type = "l",
        col = lc, lty = lt, lwd = lw)
    lines(c(-1, Nhp + 1), c(0, 0), col = "black", lty = 3, lw = 1)
    box(lwd = 1)
    dev.off()

}

## Plot LPs
for (mdl in mdls) {
    for (ee in 1:N) {
        for (xx in 1:Nx) {
            plot_lp(mdl, ores_dir, ofig_dir, xx, ee, Nhp,
                line_color, line_width, fig_size = fig_sz, yadj = adj)
        }
    }
}
