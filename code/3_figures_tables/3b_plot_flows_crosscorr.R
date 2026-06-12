## File description:
## Plot Figure 2: Cross-Correlations of Flow Probabilities and Unemployment

## Setup
rm(list = ls())
library(tis)
library(mFilter)
library(lubridate)
library(data.table)
source("./code/config.R")
source("./code/utils/set_plot_palette.R")

## SET plotting parameters
jlags <- -8:8                   ## Lags to consider
series <- c("EU", "UE", "UR")   ## Series to use
lc <- c(lc_line1)               ## Line color
lt <- c(lt_line1)               ## Line type
lw <- 3                         ## Line width
fw <- 8 / 3                     ## Figure width
fh <- 3                         ## Figure height
samp_ed <- c(2019, 4)           ## End of sample

################################################################################
## Import and clean data #######################################################
################################################################################

## Load data
load(paste0(dcln_dir, "flows_3state_adj.RData"))
load(paste0(dcln_dir, "fred_data_m.RData"))

## Select variables and merge
flows <- subset(flows_3state_adj, select = c(month, EU, UE))
unemp <- subset(fred_data_m, select = c(month, unrate))
colnames(unemp)[-1] <- "UR"
mdata <- merge(flows, unemp, by = "month", all.x = TRUE)

## Take quarterly averages
mdata$yyyy <- year(mdata$month)
mdata$mq <- (quarter(mdata$month) - 1) * 3 + 1
mdata$quarter <- make_date(mdata$yyyy, mdata$mq, 1)
mdata[, c("month", "yyyy", "mq")] <- NULL
mdata <- data.table(mdata)
qdata <- mdata[, lapply(.SD, mean, na.rm = TRUE), by = .(quarter)]

## Convert to quarterly rates
qdata$EU <- 100 * (1 - (1 - qdata$EU)^3)
qdata$UE <- 100 * (1 - (1 - qdata$UE)^3)
qdata <- data.frame(qdata)
qdata <- subset(qdata,
    year(qdata$quarter) <= samp_ed[1] & quarter(qdata$quarter) <= samp_ed[2])

## Apply Hamilton and HP filters
for (ser in series) {
    qdata[, paste0(ser, "_ham")] <- 100 * (log(qdata[, ser]) - log(
        ham_filter(qdata[, ser], 8, 4)$trend))
    qdata[, paste0(ser, "_hpf")] <- 100 * (log(qdata[, ser]) - log(
        hpfilter(qdata[, ser], freq = 1600)$trend))
}

################################################################################
## Create leads/lags and trim sample ###########################################
################################################################################

## Loop over series
for (s in series) {

    ## Loop over measures
    for (m in c("_ham", "_hpf")) {

        ## Extract
        temp <- qdata[ , paste0(s, m)]

        ## Loop over lags
        for (j in jlags) {

            ## Lags
            if (j < 0) {
                qdata[, paste0(s, m, "_l", -j)] <- lag_vector(temp, -j)
            }

            ## Leads
            if (j > 0) {
                qdata[, paste0(s, m, "_f", j)] <- lag_vector(temp, -j)
            }
        }
    }
}

## Remove NaNs
qdata_clean <- qdata[rowSums(is.na(qdata)) == 0, ]

################################################################################
## Create crosscorrelations ####################################################
################################################################################

## Preallocate
corr_ue_eu_hpf <- rep(NA, length(jlags))
corr_ue_eu_ham <- rep(NA, length(jlags))
corr_ur_eu_hpf <- rep(NA, length(jlags))
corr_ur_eu_ham <- rep(NA, length(jlags))
corr_ur_ue_hpf <- rep(NA, length(jlags))
corr_ur_ue_ham <- rep(NA, length(jlags))

## Loop
for (iij in seq_along(jlags)) {

    ## Which lag to use
    j <- jlags[iij]

    ## Lags
    if (j < 0) {

        ## Correlation: UE_t and EU_t+j
        corr_ue_eu_ham[iij] <- cor(
            qdata_clean$UE_ham, 
            qdata_clean[, paste0("EU_ham_l", -j)], method = "kendall")
        corr_ue_eu_hpf[iij] <- cor(
            qdata_clean$UE_hpf, 
            qdata_clean[, paste0("EU_hpf_l", -j)], method = "kendall")

        ## Correlation: UR_t and EU_t+j
        corr_ur_eu_ham[iij] <- cor(
            qdata_clean$UR_ham, 
            qdata_clean[, paste0("EU_ham_l", -j)], method = "kendall")
        corr_ur_eu_hpf[iij] <- cor(
            qdata_clean$UR_hpf, 
            qdata_clean[, paste0("EU_hpf_l", -j)], method = "kendall")

        ## Correlation: UR_t and UE_t+j
        corr_ur_ue_ham[iij] <- cor(
            qdata_clean$UR_ham, 
            qdata_clean[, paste0("UE_ham_l", -j)], method = "kendall")
        corr_ur_ue_hpf[iij] <- cor(
            qdata_clean$UR_hpf, 
            qdata_clean[, paste0("UE_hpf_l", -j)], method = "kendall")

    }

    ## Contemporaneous
    if (j == 0) {

        ## Correlation: UE_t and EU_t+j
        corr_ue_eu_ham[iij] <- cor(
            qdata_clean$UE_ham, qdata_clean$EU_ham, method = "kendall")
        corr_ue_eu_hpf[iij] <- cor(
            qdata_clean$UE_hpf, qdata_clean$EU_hpf, method = "kendall")

        ## Correlation: UR_t and EU_t+j
        corr_ur_eu_ham[iij] <- cor(
            qdata_clean$UR_ham, qdata_clean$EU_ham, method = "kendall")
        corr_ur_eu_hpf[iij] <- cor(
            qdata_clean$UR_hpf, qdata_clean$EU_hpf, method = "kendall")

        ## Correlation: UR_t and UE_t+j
        corr_ur_ue_ham[iij] <- cor(
            qdata_clean$UR_ham, qdata_clean$UE_ham, method = "kendall")
        corr_ur_ue_hpf[iij] <- cor(
            qdata_clean$UR_hpf, qdata_clean$UE_hpf, method = "kendall")

    }

    ## Leads
    if (j > 0) {

        ## Correlation: UE_t and EU_t+j
        corr_ue_eu_ham[iij] <- cor(
            qdata_clean$UE_ham, 
            qdata_clean[, paste0("EU_ham_f", j)], method = "kendall")
        corr_ue_eu_hpf[iij] <- cor(
            qdata_clean$UE_hpf, 
            qdata_clean[, paste0("EU_hpf_f", j)], method = "kendall")

        ## Correlation: UR_t and EU_t+j
        corr_ur_eu_ham[iij] <- cor(
            qdata_clean$UR_ham, 
            qdata_clean[, paste0("EU_ham_f", j)], method = "kendall")
        corr_ur_eu_hpf[iij] <- cor(
            qdata_clean$UR_hpf, 
            qdata_clean[, paste0("EU_hpf_f", j)], method = "kendall")

        ## Correlation: UR_t and UE_t+j
        corr_ur_ue_ham[iij] <- cor(
            qdata_clean$UR_ham, 
            qdata_clean[, paste0("UE_ham_f", j)], method = "kendall")
        corr_ur_ue_hpf[iij] <- cor(
            qdata_clean$UR_hpf, 
            qdata_clean[, paste0("UE_hpf_f", j)], method = "kendall")

    }

}

## Find peaks and troughs (hpf)
peak_ur_eu_hpf <- jlags[max(corr_ur_eu_hpf) == corr_ur_eu_hpf]
peak_ur_ue_hpf <- jlags[min(corr_ur_ue_hpf) == corr_ur_ue_hpf]
peak_ue_eu_hpf <- jlags[min(corr_ue_eu_hpf) == corr_ue_eu_hpf]

## Find peaks and troughs (ham)
peak_ur_eu_ham <- jlags[max(corr_ur_eu_ham) == corr_ur_eu_ham]
peak_ur_ue_ham <- jlags[min(corr_ur_ue_ham) == corr_ur_ue_ham]
peak_ue_eu_ham <- jlags[min(corr_ue_eu_ham) == corr_ue_eu_ham]

################################################################################
## Plot (hpf) ##################################################################
################################################################################

## Plot Correlation: UE_t and EU_t+j
pdf(paste0(ofig_dir, "flows_crosscorr_ue_eu_hpf.pdf"), width = fw, height = fh)
par(mar = c(2.5, 2.5, 1, 0.5))
par(mgp = c(1.5, 0.35, 0))
plot(jlags, corr_ue_eu_hpf, type = "l",
     ylim = c(-1, 1),
     xlab = expression(paste(italic(j), " (quarters)")),
     ylab = "Correlation coefficient",
     cex.lab = 1, cex.axis = 1,
     tck = -0.025, xaxs = "i", yaxs = "i",
     col = lc[1], lty = lt[1], lwd = lw)
lines(c(-30, 30), c(0, 0), col = "black", lty = 3, lw = 1)
lines(c(0, 0), c(-2, 2), col = "black", lty = 3, lw = 1)
lines(c(peak_ue_eu_hpf, peak_ue_eu_hpf), c(-2, 2), col = "red", lty = 2, lw = 2)
text(x = peak_ue_eu_hpf - 1.25, y = 0.825,
     labels = paste("j =", peak_ue_eu_hpf),
     srt = 0, adj = 1, cex = 0.75, col = "red")
dev.off()

## Plot Correlation: UR_t and EU_t+j
pdf(paste0(ofig_dir, "flows_crosscorr_ur_eu_hpf.pdf"), width = fw, height = fh)
par(mar = c(2.5, 2.5, 1, 0.5))
par(mgp = c(1.5, 0.35, 0))
plot(jlags, corr_ur_eu_hpf, type = "l",
     ylim = c(-1, 1),
     xlab = expression(paste(italic(j), " (quarters)")),
     ylab = "",
     cex.lab = 1, cex.axis = 1,
     tck = -0.025, xaxs = "i", yaxs = "i",
     col = lc[1], lty = lt[1], lwd = lw)
lines(c(-30, 30), c(0, 0), col = "black", lty = 3, lw = 1)
lines(c(0, 0), c(-2, 2), col = "black", lty = 3, lw = 1)
lines(c(peak_ur_eu_hpf, peak_ur_eu_hpf), c(-2, 2), col = "red", lty = 2, lw = 2)
text(x = peak_ur_eu_hpf - 1.25, y = 0.825,
     labels = paste("j =", peak_ur_eu_hpf),
     srt = 0, adj = 1, cex = 0.75, col = "red")
dev.off()

## Plot Correlation: UR_t and UE_t+j
pdf(paste0(ofig_dir, "flows_crosscorr_ur_ue_hpf.pdf"), width = fw, height = fh)
par(mar = c(2.5, 2.5, 1, 0.5))
par(mgp = c(1.5, 0.35, 0))
plot(jlags, corr_ur_ue_hpf, type = "l",
     ylim = c(-1, 1),
     xlab = expression(paste(italic(j), " (quarters)")),
     ylab = "",
     cex.lab = 1, cex.axis = 1,
     tck = -0.025, xaxs = "i", yaxs = "i",
     col = lc[1], lty = lt[1], lwd = lw)
lines(c(-30, 30), c(0, 0), col = "black", lty = 3, lw = 1)
lines(c(0, 0), c(-2, 2), col = "black", lty = 3, lw = 1)
lines(c(peak_ur_ue_hpf, peak_ur_ue_hpf), c(-2, 2), col = "red", lty = 2, lw = 2)
text(x = peak_ur_ue_hpf - 1.25, y = 0.825,
     labels = paste("j =", peak_ur_ue_hpf),
     srt = 0, adj = 1, cex = 0.75, col = "red")
dev.off()


################################################################################
## Plot (ham) ##################################################################
################################################################################

## Plot Correlation: UE_t and EU_t+j
pdf(paste0(ofig_dir, "flows_crosscorr_ue_eu_ham.pdf"), width = fw, height = fh)
par(mar = c(2.5, 2.5, 1, 0.5))
par(mgp = c(1.5, 0.35, 0))
plot(jlags, corr_ue_eu_ham, type = "l",
     ylim = c(-1, 1),
     xlab = expression(paste(italic(j), " (quarters)")),
     ylab = "Correlation coefficient",
     cex.lab = 1, cex.axis = 1,
     tck = -0.025, xaxs = "i", yaxs = "i",
     col = lc[1], lty = lt[1], lwd = lw)
lines(c(-30, 30), c(0, 0), col = "black", lty = 3, lw = 1)
lines(c(0, 0), c(-2, 2), col = "black", lty = 3, lw = 1)
lines(c(peak_ue_eu_ham, peak_ue_eu_ham), c(-2, 2), col = "red", lty = 2, lw = 2)
text(x = peak_ue_eu_ham - 1.25, y = 0.825,
     labels = paste("j =", peak_ue_eu_ham),
     srt = 0, adj = 1, cex = 0.75, col = "red")
dev.off()

## Plot Correlation: UR_t and EU_t+j
pdf(paste0(ofig_dir, "flows_crosscorr_ur_eu_ham.pdf"), width = fw, height = fh)
par(mar = c(2.5, 2.5, 1, 0.5))
par(mgp = c(1.5, 0.35, 0))
plot(jlags, corr_ur_eu_ham, type = "l",
     ylim = c(-1, 1),
     xlab = expression(paste(italic(j)," (quarters)")),
     ylab = "",
     cex.lab = 1, cex.axis = 1,
     tck = -0.025, xaxs = "i", yaxs = "i",
     col = lc[1], lty = lt[1], lwd = lw)
lines(c(-30, 30), c(0, 0), col = "black", lty = 3, lw = 1)
lines(c(0, 0), c(-2, 2), col = "black", lty = 3, lw = 1)
lines(c(peak_ur_eu_ham, peak_ur_eu_ham), c(-2, 2), col = "red", lty = 2, lw = 2)
text(x = peak_ur_eu_ham - 1.25, y = 0.825,
     labels = paste("j =", peak_ur_eu_ham),
     srt = 0, adj = 1, cex = 0.75, col = "red")
dev.off()

## Plot Correlation: UR_t and UE_t+j
pdf(paste0(ofig_dir, "flows_crosscorr_ur_ue_ham.pdf"), width = fw, height = fh)
par(mar = c(2.5, 2.5, 1, 0.5))
par(mgp = c(1.5, 0.35, 0))
plot(jlags, corr_ur_ue_ham, type = "l",
     ylim = c(-1, 1),
     xlab = expression(paste(italic(j)," (quarters)")),
     ylab = "",
     cex.lab = 1, cex.axis = 1,
     tck = -0.025, xaxs = "i", yaxs = "i",
     col = lc[1], lty = lt[1], lwd = lw)
lines(c(-30, 30), c(0, 0), col = "black", lty = 3, lw = 1)
lines(c(0, 0), c(-2, 2), col = "black", lty = 3, lw = 1)
lines(c(peak_ur_ue_ham, peak_ur_ue_ham), c(-2, 2), col = "red", lty = 2, lw = 2)
text(x = peak_ur_ue_ham - 1.25, y = 0.825,
     labels = paste("j =", peak_ur_ue_ham),
     srt = 0, adj = 1, cex = 0.75, col = "red")
dev.off()
