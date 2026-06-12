## File description:
## Make Table 4 & 5: variance decomposition

## Setup
rm(list = ls())
library(tis)
source("./code/config.R")

## SET plotting parameters
mdls <- c("zerosign", "cholesky")       ## Which specifications to use
ints <- c("", "_noint")                 ## Which interactions to use

## Loop over specifications and interactions
for (mdl in mdls)  {

    for (ii in ints) {

        ## Read in results and reform
        vd <- read.csv(paste0(
            ores_dir, mdl, "/", mdl, "_var_decomp", ii, ".csv"))
        vd[-1] <- round(vd[-1], 2)
        vd[[ncol(vd)]] <- paste0(vd[[ncol(vd)]], "\\%")

        ## Export to LaTex
        write.table(
            vd,
            paste0(otab_dir, mdl, "_var_decomp", ii, ".tex"),
            row.names = FALSE, col.names = FALSE,
            sep = " & ", eol = "\\\\ \n", quote = FALSE)
    }
}
