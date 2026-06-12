## Wrapper that loads the IPUMS extract specified by ipums_extract_num in config.R.
## On first call the microdata is read from the .dat.gz and cached to
## data/clean/cps_raw.RData; subsequent calls load the cache directly.

if (!require("ipumsr")) stop("Reading IPUMS data into R requires the ipumsr package. ",
                             "Install with: install.packages('ipumsr')")

cache_file <- paste0(dcln_dir, "cps_raw.RData")

if (file.exists(cache_file)) {
    load(cache_file)
} else {
    ddi  <- read_ipums_ddi(paste0("cps_", ipums_extract_num, ".xml"))
    data <- read_ipums_micro(ddi)
    save(data, file = cache_file)
}
