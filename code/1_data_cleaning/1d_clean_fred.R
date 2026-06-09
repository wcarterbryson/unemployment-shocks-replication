## File description:
## Clean FRED data series

## Clear workspace and load libraries
rm(list = ls())
library(lubridate)

## Load functions and set paths
source("./code/utils/utility_functions.R")
source("./code/utils/set_paths.R")

## Extract each data series from FRED format
unr <- clean_fred(fred_code = "UNRATE", data_dir = dfrd_dir)
umn <- clean_fred(fred_code = "UEMPMEAN", data_dir = dfrd_dir)
vac <- clean_fred(fred_code = "JTSJOL", data_dir = dfrd_dir)
gdp <- clean_fred(fred_code = "GDPC1", data_dir = dfrd_dir)

## Merge and save monthly data
fred_data_m <- merge(unr, umn, by = "month", all.x = TRUE)
fred_data_m <- merge(fred_data_m, vac, by = "month", all.x = TRUE)
save(fred_data_m, file = paste0(dcln_dir, "fred_data_m.RData"))

## Merge and save quarterly data
fred_data_q <- gdp
colnames(fred_data_q)[1] <- "quarter"
save(fred_data_q, file = paste0(dcln_dir, "fred_data_q.RData"))
