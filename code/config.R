## File description:
## Project configuration — set user-specific options here

library(here)

## Load utility functions
source(here("code", "utils", "utility_functions.R"))

# SET: Your IPUMS CPS extract number (zero-padded, e.g. "00145" for cps_00145.xml)
ipums_extract_num <- "00145"

## Master path (derived automatically from project root)
mast_path <- here()

## Main directories
code_dir <- here("code")                                    ## Path to code
data_dir <- here("data")                                    ## Path to data
outp_dir <- here("output")                                  ## Path to output

## Data sub-directories
dcln_dir <- paste0(here("data", "clean"), "/")              ## Path to clean data
draw_dir <- paste0(here("data", "raw"), "/")                ## Path to raw data

## Raw data sub-directories
dbls_dir <- paste0(here("data", "raw", "BLS"), "/")         ## BLS data
dfrd_dir <- paste0(here("data", "raw", "FRED"), "/")        ## FRED data
dcps_dir <- paste0(here("data", "raw", "IPUMS_CPS"), "/")   ## IPUMS CPS data
dshm_dir <- paste0(here("data", "raw", "Shimer"), "/")      ## Shimer data

## Output sub-directories
ofig_dir <- paste0(here("output", "figures"), "/")          ## Path to figures
ores_dir <- paste0(here("output", "results"), "/")          ## Path to results
otab_dir <- paste0(here("output", "tables"),  "/")          ## Path to tables
