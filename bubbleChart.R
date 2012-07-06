# Bubble chart from PLoS Article Level Metrics data
# Version 1.0, 07/05/12
# by Martin Fenner, mf@martinfenner.org

# Load data
alm <- read.csv("alm_out.csv", header=TRUE)
radius <- sqrt( alm$citeulike / pi )

# Labels
plos.title <- "John P. A. Ioannidis"
plos.xlab <- "Months since Publication"
plos.ylab <- "CrossRef Citations"

# Plot the chart
opar <- par(mai=c(1.5,1.5,1.5,1.5), fg="black", cex.main=2, col.main="#1d479b", xaxs="i")
symbols(alm$age_in_days / 365.25 * 12, alm$crossref, circles=radius, inches=0.1, fg="black", bg="#548aee", xlab=plos.xlab, ylab=plos.ylab, main=paste("Article Level Metrics for", plos.title),xaxt="s")
#text(alm$age_in_days / 365.25 * 12, alm$crossref, alm$doi, pos=3, offset=0.75, cex=0.5)
par(opar)