## File description:
## Clean all data

## Clear workspace and load libraries
rm(list = ls())
library(zoo)
library(plyr)
library(seasonal)
library(openxlsx)
library(lubridate)
library(data.table)

## Load functions and set paths
source("./code/config.R")

## Create output directories if they don't exist
dir.create(dcln_dir, recursive = TRUE, showWarnings = FALSE)

## Print progress to screen
print("-----------------------------------------------------------------------")
print("--- 1: Clean data -----------------------------------------------------")
print("-----------------------------------------------------------------------")

## Clean data
source("./code/1_data_cleaning/1a_clean_flows_2state.R")
source("./code/1_data_cleaning/1b_clean_flows_3state.R")
source("./code/1_data_cleaning/1c_clean_shimer.R")
source("./code/1_data_cleaning/1d_clean_fred.R")
source("./code/1_data_cleaning/1e_make_svar_data.R")
