## File description:
## Set all paths here

library(here)

## Master path (derived automatically from project root)
mast_path <- here()

## Main directories
code_dir <- here("code")        ## Path to Code
data_dir <- here("data")        ## Path to Data
outp_dir <- here("output")      ## Path to Output

## Data sub-directories
dcln_dir <- here("data", "clean")       ## Path to clean data
draw_dir <- here("data", "raw")         ## Path to raw data

## Raw data sub-directories
dbls_dir <- here("data", "raw", "BLS")         ## BLS data
dfrd_dir <- here("data", "raw", "FRED")        ## FRED data
dcps_dir <- here("data", "raw", "IPUMS_CPS")   ## IPUMS CPS data
dshm_dir <- here("data", "raw", "Shimer")      ## Shimer data

## Output sub-directories
ofig_dir <- paste0(here("output", "figures"), "/")  ## Path to figures
ores_dir <- paste0(here("output", "results"), "/")  ## Path to results
otab_dir <- paste0(here("output", "tables"),  "/")  ## Path to tables
