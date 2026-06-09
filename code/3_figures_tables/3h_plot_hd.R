## File description:
## Plot Figure 8 and 9: Historical Decomposition

## Setup
rm(list = ls())
library(tis)
source("./code/utils/utility_functions.R")
source("./code/utils/set_paths.R")
source("./code/utils/set_plot_palette.R")

## SET plotting parameters
mdls <- c("zerosign", "cholesky")   ## Which specifications to use
fig_sz <- c(4, 8 / 3)               ## Figure (width, height)
N <- 4                              ## Number of variables
lw <- 2                             ## Line width
zeroline_tis <- tis(0, start = 1970, end = 2030, tif = "quarterly")
ac <- c(lc_line2, lc_line3, lc_line4, lc_line7)
leg <- c("Inflow", "Outflow", "Level", "Length")

## SET options for 2001 recessions
ylims_2001 <- list(
    c(-20, 15),
    c(-20, 15),
    c(-40, 30),
    c(-25, 45)
)
st_2001 <- ti(c(2000, 1), tif = "quarterly")
ed_2001 <- ti(c(2003, 4), tif = "quarterly")
lpos_2001 <- c(2004, 16)

## SET options for 2008 recessions
ylims_2008 <- list(
    c(-20, 40),
    c(-45, 10),
    c(-30, 80),
    c(-20, 80)
)
st_2008 <- ti(c(2007, 1), tif = "quarterly")
ed_2008 <- ti(c(2010, 4), tif = "quarterly")
lpos_2008 <- c(2011, 40)

## Define function
plot_hd <- function(mdl, in_dir, out_dir, vv, N, year_rec, st_rec, ed_rec, 
    ylims_rec, leg, lc, lw, zeroline, lpos, fig_size = c(4, 3)) {

    ## Read in HD
    hd_name <- paste0(mdl, "_hd_v", vv)
    filename <- paste0(in_dir, mdl, "/", hd_name, ".csv")
    hd <- read.csv(filename, header = FALSE, stringsAsFactors = FALSE)

    ## Change column names
    colnames(hd) <- c("yyyy", "q", "Yt", paste0("Yh", 1:N))
    tis_st <- c(hd$yyyy[1], hd$q[1])

    ## Convert to tis
    hd_tis <- tis(hd[paste0("Yh", 1:N)], start = tis_st, tif = "quarterly")
    y_tis <- tis(hd$Yt, start = tis_st, tif = "quarterly")

    ## Get legend text
    if (vv == 1) {
        leg_text <- leg
    } else {
        leg_text <- FALSE
    }

    ## Plot recession
    pdf(paste0(out_dir, "/", mdl, "/", hd_name, "_", year_rec, ".pdf"),
        width = fig_size[1], height = fig_size[2])
    par(mar = c(1.5, 1.5, 0.5, 0.5))
    par(mgp = c(1.5, 0.35, 0))
    par(xpd = FALSE)
    tisPlot(window(y_tis, start = st_rec, end = ed_rec),
        nberShade = TRUE,
        leftTopLabel = "Percent Deviation from Trend", labCex = 0.9,
        tck = 0.015, xSpace = 0,
        labelRightTicks = FALSE, labelLeftTicks = TRUE,
        xTickFreq = "Annual", xTickSkip = 0, midPoints = TRUE,
        xAxisMin = st_rec,
        leftAxisMin = ylims_rec[[vv]][1], rightAxisMin = ylims_rec[[vv]][1],
        leftAxisMax = ylims_rec[[vv]][2], rightAxisMax = ylims_rec[[vv]][2],
        leftMargin = 2, rightMargin = 0.25, topMargin = 1, bottomMargin = 1)
    a <- barplot(window(hd_tis, start = st_rec, end = ed_rec),
        space = 0.25, col = ac, add = TRUE, xpd = FALSE, beside = FALSE,
        legend.text = leg_text,
        args.legend = list(x = lpos[1], y = lpos[2], bty = "n", cex = 0.9))
    lines(window(y_tis, start = st_rec, end = ed_rec),
        lwd = 2, col = "black")
    lines(zeroline, col = "black", lty = 1, lwd = lw)
    dev.off()

}

## Plot 2001 recession
for (mdl in mdls) {
    for (vv in 1:N) {
        plot_hd(mdl, ores_dir, ofig_dir, vv, N, 2001,
            st_2001, ed_2001, ylims_2001, leg, ac,
            lw_zerol, zeroline_tis, lpos_2001, fig_size = fig_sz)
    }
}

## Plot 2008 recession
for (mdl in mdls) {
    for (vv in 1:N) {
        plot_hd(mdl, ores_dir, ofig_dir, vv, N, 2008,
            st_2008, ed_2008, ylims_2008, leg, ac,
            lw_zerol, zeroline_tis, lpos_2008, fig_size = fig_sz)
    }
}
