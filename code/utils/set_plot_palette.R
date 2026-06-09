## File description:
## Create palette for figures

################################################################################
## Setup #######################################################################
################################################################################

## Define colors here
rgb_black         <- c(  0 / 256,   0 / 256,   0 / 256) ## Black
rgb_vermillion    <- c(213 / 256,  94 / 256,   0 / 256) ## Vermillion
rgb_blue          <- c(  0 / 256, 114 / 256, 178 / 256) ## Blue
rgb_bluishgreen   <- c(  0 / 256, 158 / 256, 115 / 256) ## Bluish Green
rgb_skyblue       <- c( 86 / 256, 180 / 256, 233 / 256) ## Sky Blue
rgb_orange        <- c(230 / 256, 159 / 256,   0 / 256) ## Orange
rgb_reddishpurple <- c(204 / 256, 121 / 256, 167 / 256) ## Reddish Purple
rgb_yellow        <- c(240 / 256, 228 / 256,  66 / 256) ## Yellow

################################################################################
## Chart colors ################################################################
################################################################################

## Set colors for plotting two lines on the same graph
lc_line1 <- rgb_black
lc_line2 <- rgb_vermillion

## Set colors for plotting more than two lines on the same graph
lc_line3 <- rgb_blue
lc_line4 <- rgb_bluishgreen
lc_line5 <- rgb_orange
lc_line6 <- rgb_skyblue
lc_line7 <- rgb_reddishpurple

################################################################################
## Chart line types ############################################################
################################################################################

## Line types for plotting two lines on the same graph
## Used for trends, model vs. data, etc.
lt_line1 <- 1
lt_line2 <- 2
lt_line3 <- 4
lt_line4 <- 5
lt_line5 <- 6
lt_line6 <- 1
lt_line7 <- 5

################################################################################
## Chart line widths ###########################################################
################################################################################

## Different line types for different charts
lw_deflt <- 3.5  ## Default
lw_thick <- 4    ## Thick
lw_thinn <- 3    ## Thin

################################################################################
## Legends and labels ##########################################################
################################################################################

## Legend sizes
leg_sz <- 0.85 ## Cex scaling factor for legends

################################################################################
## Line at 0 ###################################################################
################################################################################

## Parameters
lc_zerol <- rgb_black
lt_zerol <- 2
lw_zerol <- 1.5

## Convert
lc_zerol <- c(rgb(lc_zerol[1], lc_zerol[2], lc_zerol[3]))

################################################################################
## Convert colors ##############################################################
################################################################################

## Convert rgb codes: two lines
lc_line1 <- c(rgb(lc_line1[1], lc_line1[2], lc_line1[3]))
lc_line2 <- c(rgb(lc_line2[1], lc_line2[2], lc_line2[3]))

## Convert rgb codes: more lines
lc_line3 <- c(rgb(lc_line3[1], lc_line3[2], lc_line3[3]))
lc_line4 <- c(rgb(lc_line4[1], lc_line4[2], lc_line4[3]))
lc_line5 <- c(rgb(lc_line5[1], lc_line5[2], lc_line5[3]))
lc_line6 <- c(rgb(lc_line6[1], lc_line6[2], lc_line6[3]))
lc_line7 <- c(rgb(lc_line7[1], lc_line7[2], lc_line7[3]))
