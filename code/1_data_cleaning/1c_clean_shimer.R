## File description:
## Clean Shimer (2012) original data series

## Clear workspace and load libraries
rm(list = ls())
library(lubridate)

## Load functions and set paths
source("./code/utils/utility_functions.R")
source("./code/utils/set_paths.R")

## Define function: Clean Shimer data
clean_shimer <- function(data_dir, file_name, series_name) {

    ## Read in flat file
    ab <- read.table(paste0(data_dir, file_name), stringsAsFactors = FALSE)

    ## Clean data
    ab$dates <- gsub("\\{", "", ab$V1)
    ab$dates <- as.numeric(gsub(",", "", ab$dates))
    ab$data <- as.numeric(gsub("}", "", ab$V2))

    ## Create quarterly dates (e.g., first day of each quarter)
    quarter_start_months <- c(1, 4, 7, 10)
    yyyy <- floor(ab$dates)
    qq <- floor((ab$dates %% 1) * 4) + 1
    mm <- quarter_start_months[qq]
    ab$quarter <- make_date(year = yyyy, month = mm, day = 1)

    ## Keep and return
    out_data <- subset(ab, select = c(quarter, data))
    colnames(out_data)[-1] <- series_name
    return(out_data)

}

## Clean Shimer data
shimer_ue2 <- clean_shimer(dshm_dir, "find-prob.dat", "Ft")
shimer_eu2 <- clean_shimer(dshm_dir, "sep-prob.dat", "Xt")
shimer_ue <- clean_shimer(dshm_dir, "ue.dat", "UE")
shimer_eu <- clean_shimer(dshm_dir, "eu.dat", "EU")
shimer_ne <- clean_shimer(dshm_dir, "ie.dat", "NE")
shimer_en <- clean_shimer(dshm_dir, "ei.dat", "EN")
shimer_nu <- clean_shimer(dshm_dir, "iu.dat", "NU")
shimer_un <- clean_shimer(dshm_dir, "ui.dat", "UN")

## Merge and save
flows_shimer <- merge(shimer_ue2, shimer_eu2, by = "quarter", all.x = TRUE)
flows_shimer <- merge(flows_shimer, shimer_ue, by = "quarter", all.x = TRUE)
flows_shimer <- merge(flows_shimer, shimer_eu, by = "quarter", all.x = TRUE)
flows_shimer <- merge(flows_shimer, shimer_ne, by = "quarter", all.x = TRUE)
flows_shimer <- merge(flows_shimer, shimer_en, by = "quarter", all.x = TRUE)
flows_shimer <- merge(flows_shimer, shimer_nu, by = "quarter", all.x = TRUE)
flows_shimer <- merge(flows_shimer, shimer_un, by = "quarter", all.x = TRUE)
save(flows_shimer, file = paste0(dcln_dir, "flows_shimer.RData"))
