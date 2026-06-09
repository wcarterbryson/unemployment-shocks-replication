## File description:
## Repository for useful functions
library(lubridate)

################################################################################
## Function: clean_fred. Clean arbitrary data series from FRED. ################
##  - Note: Assumes DATE variable is in YYYY-MM-DD format.
##  - Inputs:
##      + fred_code  : FRED code for data series
##      + data_dir   : path to FRED data directory
## - Outputs:
##      + dat_raw    : cleaned data
################################################################################
clean_fred <- function(fred_code, data_dir) {

    ## Import each data series
    dat_raw <- read.csv(
        paste0(data_dir, fred_code, ".csv"), 
        stringsAsFactors = FALSE, na.strings = ".")

    ## Get name of variable
    dat_name <- tolower(colnames(dat_raw)[2])

    ## Extract data series
    dat <- as.numeric(dat_raw[, 2])

    ## Extract date information
    yyyy <- as.numeric(substr(dat_raw$observation_date, 1, 4))
    mm <- as.numeric(substr(dat_raw$observation_date, 6, 7))
    dd <- as.numeric(substr(dat_raw$observation_date, 9, 10))
    month <- make_date(yyyy, mm, dd)

    ## Create new data frame
    dat_out <- data.frame(month, dat)
    colnames(dat_out)[-1] <- dat_name

    ## Return
    return(dat_out)

}

################################################################################
## Function: ham_filter. Filters time series using Hamilton (2018) method ######
##  - Note: by default, returns the cyclical component
##  - Inputs:
##      + yt : raw time series
##      + h : horizon parameter
##      + p : lag parameter
## - Outputs:
##      + yt_filtered : Hamilton filtered time series
################################################################################
ham_filter <- function(yt, h, p) {

    ## Get number of time periods
    Nt <- length(yt)

    ## Create Y vector
    Y <- yt

    ## Loop to create X matrix
    X <- matrix(1, Nt, 1)
    for (l in h:(h + p - 1)) {
        X <- cbind(X, c(rep(NA, l), head(yt, -l)))
    }

    ## Trim NA's in Y and XX
    Y <- Y[rowSums(is.na(X)) == 0]
    X <- X[rowSums(is.na(X)) == 0, ]

    ## Run OLS
    B <- solve(t(X) %*% X) %*% (t(X) %*% Y)

    ## Obtain fitted values and residuals
    Y_hat <- X %*% B
    U_hat <- Y - Y_hat

    ## Replace with NA's
    nlags <- Nt - length(Y_hat)
    yt_hat <- c(rep(NA, nlags), Y_hat)
    ut_hat <- c(rep(NA, nlags), U_hat)

    ## Pack output and return
    yt_filtered <- list("cycle" = ut_hat, "trend" = yt_hat,
                        "ldiff" = log(yt / yt_hat))
    return(yt_filtered)

}

################################################################################
## Function: lag_vector. Obtain arbitrary lead/lag of time series vector. ######
##  - Note: Does not work with matrices. Can only handle one vector at a time.
##  - Inputs:
##      + vect : vector to lead/lag
##      + l : number of leads/lags
## - Outputs:
##      + lvect : lead/lag vector
################################################################################
lag_vector <- function(vect, l) {

    ## Check if lag > 1 (lag) or lag < 1 (lead)
    if (l > 0) {
        lvect <- c(rep(NA, l), head(vect, -l))
    } else if (l < 0) {
        lvect <- c(tail(vect, l), rep(NA, -l))
    } else if (l == 0) {
        lvect <- vect
    } else {
        stop("Number of lags must be an integer")
    }

    ## Return
    return(lvect)

}

################################################################################
## Function: lin_filter. Create a linear time trend to detrend.
##  - Note: by default, returns the cyclical component
##  - Inputs:
##      + yt : raw time series
##      + n : order of the filter (default: n = 1)
## - Outputs:
##      + yt_filtered : filtered time series
################################################################################
lin_filter <- function(yt, n = 1) {

    ## Get number of time periods
    Nt <- length(yt)

    ## Create Y vector
    Y <- yt

    ## Loop to create X matrix
    X <- matrix(1, Nt, n + 1)
    X[, 1] <- 1
    for (ii in 1:n) {
        X[, ii + 1] <- (1:Nt)^ii
    }

    ## Trim NA's in Y and XX
    Y <- Y[rowSums(is.na(X)) == 0]
    X <- X[rowSums(is.na(X)) == 0, ]

    ## Run OLS
    B <- solve(t(X) %*% X) %*% (t(X) %*% Y)

    ## Obtain fitted values and residuals
    Y_hat <- X %*% B
    U_hat <- Y - Y_hat

    ## Replace with NA's
    nlags <- Nt - length(Y_hat)
    yt_hat <- c(rep(NA, nlags), Y_hat)
    ut_hat <- c(rep(NA, nlags), U_hat)

    ## Pack output and return
    yt_filtered <- list("cycle" = ut_hat, "trend" = yt_hat,
                        "ldiff" = log(yt / yt_hat))
    return(yt_filtered)

}

################################################################################
## Function: my_granger_clean. Implement F-test for Granger causality ##########
##  - Note: Follows Hamilton (1992) Chapter [11.2].
##  - Inputs:
##      + eq : Equation to test "Y ~ X" for X Granger causes Y
##      + dat : dataset to use (must have lags pre-loaded)
##      + alph : significance level (default = 1%)
##      + p : number of lags (default = 1)
##  - Outputs:
##      + h : result of the hypothesis test (h = 1: reject the null)
##      + S1 : test statistic
##      + c : critical value
##      + pval : p-value of the test
##      + stats : information (e.g. R-squared) on the restricted and
##          unrestricted regressions
################################################################################
my_granger_clean <- function(eq, dat, alph = 0.01, p = 1) {

    ## Unpack Y and X variables
    yyvar <- gsub(" ", "", strsplit(eq, "~")[[1]][1], fixed = TRUE)
    xxvar <- gsub(" ", "", strsplit(eq, "~")[[1]][2], fixed = TRUE)

    ## Construct matrix of regressors
    LY <- dat[, paste0(yyvar, "_l", 1:p)]
    LX <- dat[, paste0(xxvar, "_l", 1:p)]

    ## Run unrestricted regression
    Y1 <- dat[, yyvar]
    X1 <- cbind(1, LY, LX)
    X1 <- data.matrix(X1)
    if (any(is.na(Y1)) || any(is.na(X1))) {
        stop("Data should not contain NAs")     ## Check for NA's
    }
    NT1 <- length(Y1)                           ## Get number of observations
    G1 <- solve((t(X1) %*% X1), (t(X1) %*% Y1)) ## Run OLS
    u <- Y1 - X1 %*% G1                         ## Compute residuals
    u2 <- u^2                                   ## Compute residuals^2
    RSS1 <- sum(u2)
    TSS1 <- sum((Y1 - mean(Y1))^2)
    rsq1 <- 1 - (RSS1 / TSS1)
    adjrsq1 <- 1 - ((1 - rsq1) * (NT1 - 1)) / (NT1 - 2 * p - 1)
    sig2hat1 <- (1 / (NT1 - 1)) * RSS1
    LL1 <- -(NT1 / 2) * log(2 * pi) - (NT1 / 2) *
        log(sig2hat1) - (1 / (2 * sig2hat1)) * (sum(u2))
    AIC1 <- -2 * LL1 + 2 * ncol(X1)
    BIC1 <- -2 * LL1 + log(NT1) * ncol(X1)

    ## Run restricted regression
    Y0 <- dat[, yyvar]
    X0 <- cbind(1, LY)
    X0 <- data.matrix(X0)
    NT0 <- length(Y0)                           ## Get number of observations
    G0 <- solve((t(X0) %*% X0), (t(X0) %*% Y0)) ## Run OLS
    e <- Y0 - X0 %*% G0                         ## Compute residuals
    e2 <- e^2                                   ## Compute residuals^2
    RSS0 <- sum(e2)
    TSS0 <- sum((Y0 - mean(Y0))^2)
    rsq0 <- 1 - (RSS0 / TSS0)
    adjrsq0 <- 1 - ((1 - rsq0) * (NT0 - 1)) / (NT0 - 2 * p - 1)

    ## Compute test statistic
    S1 <- ((RSS0 - RSS1) / p) / (RSS1 / (NT1 - 2 * p - 1))

    ## Compute critical value
    c <- qf(1 - alph, p, NT1 - 2 * p - 1)

    ## Compute p-value of the test statistic
    pval <- 1 - pf(S1, p, NT1 - 2 * p - 1)

    ## Conduct hypothesis test
    h <- S1 > c

    ## Pack output
    res <- list(h = h, S1 = S1, c = c, pval = pval,
        adjrsq1 = adjrsq1, adjrsq0 = adjrsq0,
        rsq1 = rsq1, rsq0 = rsq0, AIC1 = AIC1, BIC1 = BIC1)
    return(res)

}
