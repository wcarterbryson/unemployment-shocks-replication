## File description:
## Make all figures and tables

## Clear workspace and load libraries
rm(list = ls())
library(tis)
library(mFilter)
library(lubridate)
library(data.table)

## Load functions and set paths
source("./code/utils/utility_functions.R")
source("./code/utils/set_paths.R")

## Create output directories if they don't exist
for (d in c(ofig_dir, otab_dir,
            paste0(ofig_dir, "cholesky"),
            paste0(ofig_dir, "zerosign"))) {
    dir.create(d, recursive = TRUE, showWarnings = FALSE)
}

## Print progress to screen
print("-----------------------------------------------------------------------")
print("--- 3: Make figures and tables ----------------------------------------")
print("-----------------------------------------------------------------------")

## Main text: motivating evidence
source("./code/3_figures_tables/3a_plot_flows_cyclicality.R")   ## Figure 1
source("./code/3_figures_tables/3b_plot_flows_crosscorr.R")     ## Figure 2
source("./code/3_figures_tables/3c_make_granger_table.R")       ## Table 1 & 2

## Main text: SVAR results
source("./code/3_figures_tables/3d_plot_ir.R")                 ## Figure 3 & 4
source("./code/3_figures_tables/3e_plot_lp.R")                  ## Figure 5 & 6
source("./code/3_figures_tables/3f_make_var_decomp_table.R")    ## Table 4 & 5
source("./code/3_figures_tables/3g_plot_fevd.R")                ## Figure 7
source("./code/3_figures_tables/3h_plot_hd.R")                  ## Figure 8 & 9

## Appendix
source("./code/3_figures_tables/3i_plot_shimer_2state.R")       ## Figure A.1
source("./code/3_figures_tables/3j_plot_shimer_3state.R")       ## Figure A.2
source("./code/3_figures_tables/3k_plot_2state_vs_3state.R")    ## Figure A.3
