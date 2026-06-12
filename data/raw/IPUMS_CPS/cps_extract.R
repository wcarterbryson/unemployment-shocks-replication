## Wrapper that loads the IPUMS extract specified by ipums_extract_num in config.R.
## Only the columns needed by downstream scripts are read to reduce memory usage.
## On first call the microdata is cached to data/clean/cps_raw.RData;
## subsequent calls load the cache directly.

if (!require("ipumsr")) stop("Reading IPUMS data into R requires the ipumsr package. ",
                             "Install with: install.packages('ipumsr')")

## Columns used by 1a (clean_flows_2state) and 1b (clean_flows_3state)
cps_vars <- c("YEAR", "MONTH", "LABFORCE", "AGE", "CPSIDV",
              "EMPSTAT", "MISH", "LNKFW1MWT", "WTFINL", "DURUNEMP")

cache_file <- paste0(dcln_dir, "cps_raw.RData")

if (file.exists(cache_file)) {
    load(cache_file)
} else {
    ddi          <- read_ipums_ddi(paste0("cps_", ipums_extract_num, ".xml"))
    ddi$var_info <- ddi$var_info[ddi$var_info$var_name %in% cps_vars, ]
    data         <- read_ipums_micro(ddi)
    save(data, file = cache_file)
}
