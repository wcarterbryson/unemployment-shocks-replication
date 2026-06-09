# The Ins and Outs of Unemployment Shocks
Do unemployment inflows or outflows drive unemployment fluctuations?

## Directory structure
```plaintext
unemployment-shocks/
├── code/
|   │── 1_data_cleaning/    # R code to clean data series
|   │   ├── run_1.R         # Master program: run all scripts in directory
|   │── 2_svar_analysis/    # Matlab code to estimate shocks
|   │   ├── run_2.m         # Master program: run all scripts in directory
|   │── 3_figures_tables/   # R code to create all figures and tables
|   │   ├── run_3.R         # Master program: run all scripts in directory
│   └── utils/              # Helper R scripts and functions 
├── data/
│   |── clean/              # Cleaned data files (produced by run_1.R)
│   └── raw/                # Raw data files
├── draft/
├── output/
│   ├── figures/            # Figures (produced by run_3.R)
│   ├── results/            # Estimation results (produced by run_2.m)
│   └── tables/             # Tables (produced by run_3.R)
```

## Table of contents
*   [Code documentation](#code_documentation)
*   [Data documentation](#data_documentation)

# Code documentation <a name="code_documentation"></a>

## Running the code
To produce the figures and tables in the draft, follow the steps below:

0. Ensure that all necessary raw data files are updated and saved in `data/raw/` (see data documentation below for additional details).
1. Run `code/1_data_cleaning/run_1.R` to produce the clean data files in `data/clean/`.
    - Paths are set automatically — no manual path editing required for R.
    - Note that some parameters (e.g. sample start/end dates) are set manually in the sub-scripts and functions in `code/1_data_cleaning/`.
    - Most importantly, this script produces the file `data/clean/svar_data.csv`, which contains the data used in the SVAR analysis.
2. Run `code/2_svar_analysis/run_2.m` to run the Matlab code that conducts the SVAR analysis.
    - Set the path to the Empirical Macro Toolbox in `code/2_svar_analysis/set_paths.m` (one line). All other paths are set automatically.
    - Make sure to set required parameters in `code/2_svar_analysis/set_paras.m`.
    - This script produces several .csv files containing estimation results that are saved in `output/results/`
3. Run `code/3_figures_tables/run_3.R` to produce the figures and tables.
    - Note that some plotting parameters are set manually in the sub-scripts and functions in `code/3_figures_tables/`.

## Software requirements

### Matlab
- Version: R2023a
- Toolboxes:
    - [Empirical Macro Toolbox](https://github.com/naffe15/BVAR_) (Ferroni and Canova, 2025)

### R
- Version: `R version 4.4.3 (2025-02-28 ucrt) -- "Trophy Case"`
- Packages:
  
    | Package       | Version   |
    |---------------|-----------|
    | `areaplot`    | 2.1.3     |    
    | `data.table`  | 1.16.2    |
    | `here`        | 1.0.2     |
    | `ipumsr`      | 0.8.1     |
    | `lubridate`   | 1.9.4     |
    | `mFilter`     | 0.1.5     |
    | `openxlsx`    | 4.2.8     |
    | `plyr`        | 1.8.9     |
    | `seasonal`    | 1.10.0    |    
    | `tis`         | 1.39      |
    | `zoo`         | 1.8.13    |

# Data documentation <a name="data_documentation"></a>

## Bureau of Labor Statistics (BLS) Labor Force Statistics (LFS) Database

- To create the data file `bls_lfs_stocks_raw.txt`, follow the steps below:
    1. Navigate to https://data.bls.gov/cgi-bin/srgate
    2. Enter the following series ids in the text field
        - LNS13008396: Number Unemployed for Less than 5 Weeks
        - LNS12000000: Employment Level
        - LNS13000000: Unemployment Level
    3. Click "Retrieve Data"
    4. Reformat as: 
        - Multi-series table
        - Years: 1948–2024
        - Output Type: Text (comma-delimited)
    5. Copy and paste the resulting table into a .txt file
        - NOTE: Use .txt instead of .csv because Excel reformats dates
    6. Save the file to `data/raw/BLS/`

## Current Population Survey (CPS)

### Data extracts
- I download raw CPS data extracts from [IPUMS CPS](https://cps.ipums.org/cps/).
- The raw CPS extract files are **not included** in this repository (IPUMS does not permit redistribution). To recreate them, follow the steps below:
    1. Navigate to IPUMS CPS website
    2. Create a new extract ("Get Data")
    3. Select the variables below

        | Type	| Variable      | Label                                                     |
        | ----  | ----          | --------------------------------------------------------- |
        | H	    | `YEAR`        |	Survey year                                             |
        | H	    | `SERIAL`      |	Household serial number                                 |
        | H	    | `MONTH`       |	Month                                                   |
        | H	    | `HWTFINL`     |	Household weight, Basic Monthly                         |
        | H	    | `CPSID`       |	CPSID, household record                                 |
        | H	    | `ASECFLAG`    |	Flag for ASEC                                           |
        | H	    | `MISH`        |	Month in sample, household level                        |
        | P	    | `PERNUM`      |	Person number in sample unit                            |
        | P	    | `WTFINL`      |	Final Basic Weight                                      |
        | P	    | `CPSIDV`      |	Validated Longitudinal Identifier                       |
        | P	    | `CPSIDP`      |	CPSID, person record                                    |
        | P	    | `AGE`         |	Age                                                     |
        | P	    | `SEX`         |	Sex                                                     |
        | P	    | `RACE`        |	Race                                                    |
        | P	    | `EMPSTAT`     |	Employment status                                       |
        | P	    | `LABFORCE`    |	Labor force status                                      |
        | P	    | `DURUNEMP`    |	Continuous weeks unemployed                             |
        | P	    | `LNKFW1MWT`   |	Longitudinal weight for two adjacent months (BMS only)  |

    4. Select the samples below
        - Basic Monthly: 1976–2024, all months
    5. Submit the extract ("CREATE DATA EXTRACT")
    6. Once the extract is ready, save the following files to `data/raw/IPUMS_CPS/`, renaming them as shown:
        - `cps_extract.dat.gz` : raw data file
        - `cps_extract.R` : R file to unpack data
        - `cps_extract.xml` : data dictionary file

### Sample

The table below shows the months that can be linked in the CPS Basic Monthly files.

| Years     | Jan     | Feb     | Mar     | Apr     | May     | Jun     | Jul     | Aug     | Sep     | Oct     | Nov     | Dec     |
|-----------|---------|---------|---------|---------|---------|---------|---------|---------|---------|---------|---------|---------|
| 1976      | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; | –       |
| 1977      | –       | &check; | &check; | –       | &check; | –       | –       | –       | –       | –       | –       | &check; |
| 1978–1984 | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; |
| 1985      | &check; | &check; | &check; | &check; | &check; | –       | &check; | &check; | –       | &check; | &check; | &check; |
| 1986–1994 | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; |
| 1995      | &check; | &check; | &check; | &check; | –       | &check; | &check; | –       | &check; | &check; | &check; | &check; |
| 1996–2024 | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; | &check; |

- NOTE: In my empirical analysis, I drop the years 1976 and 1977 because there are several unlinkable months.

### Adjustments

I adjust the raw three-state grossflows data for seasonality and time-aggregation bias, as in Shimer (2012). The specific sequence of adjustment steps is below. Appendix A in the draft contains additional details.

- Adjustment steps:
    1. Start with raw grossflows series
    2. Convert to proportions (divide by population in each time period)
    3. Interpolate NA values using last observation carried forward (LOCF)
    4. Seasonally adjust using Census X-13 (R library `seasonal`)
    5. Calculate flow probabilities
    6. Adjust flow probabilities for time aggregation bias
    7. Calculate implied stocks using perpetual inventory method
    8. Calculate implied grossflow proportions (`pi_ij = stock_i * flow_ij`)

## Federal Reserve Economic Data (FRED)

I download the following series from [FRED](https://fred.stlouisfed.org/):

| Series Name                   | FRED Code | Units                             | Sample                |
|-------------------------------|-----------|---------------------------------- | ----------------------|
| Real Gross Domestic Product   | GDPC1     | Billions of Chained 2017 Dollars  | Q1 1947–Q3 2025      |
| Job Openings: Total Nonfarm   | JTSJOL    | Level in Thousands                | Dec 2000–Nov 2025    |
| Average Weeks Unemployed      | UEMPMEAN  | Number of Weeks                   | Jan 1948–Nov 2025    |
| Unemployment Rate             | UNRATE    | Percent                           | Jan 1948–Nov 2025    |

- The .csv files for each series are saved in `data/raw/FRED/`.

## Miscellaneous

### Barnichon (2010)

I download the vacancy posting series from [Regis Barnichon's website](https://sites.google.com/site/regisbarnichon/research). The excel file `CompositeHWI.xlsx` is saved in `data/raw/Barnichon/`.

Citation: Regis Barnichon,
Building a composite Help-Wanted Index,
Economics Letters,
Volume 109, Issue 3,
2010,
Pages 175-178,
ISSN 0165-1765,
https://doi.org/10.1016/j.econlet.2010.08.029.

### Shimer (2012)

I download the original estimates of the job-finding and employment-exit probabilities from [Rob Shimer's website](https://sites.google.com/site/robertshimer/research/flows). The flat files (.dat) are saved in `data/raw/Shimer/`.

Citation: Robert Shimer,
Reassessing the ins and outs of unemployment,
Review of Economic Dynamics,
Volume 15, Issue 2,
2012,
Pages 127-148,
ISSN 1094-2025,
https://doi.org/10.1016/j.red.2012.02.001.
