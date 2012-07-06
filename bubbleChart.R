# Bubble chart from PLoS Article Level Metrics data
# Version 1.0, 07/05/12
# by Martin Fenner, mf@martinfenner.org

# Load data
alm <- read.csv("alm_out.csv", header=TRUE)
x <- alm$age_in_days
y <- alm$Counter + alm$PubMed.Central.Usage.Stats
z <- sqrt( alm$CrossRef / pi )

# Labels
main <- "Médicins sans Frontières\n"
today <- format(Sys.Date(), "%B %e, %Y")
sub <- sprintf("PLoS Article Level Metrics Report (%s)", today)
plos.xlab <- "Months"
plos.ylab <- "Cumulative Views"

# Plot the chart
opar <- par(mai=c(1.5,1.5,1.5,1.5), mgp=c(3.5,1,0), fg="grey", cex.main=2, cex.sub=1.25, cex.lab=1.5, col="white", col.main="#1d479b", col.sub="#1d479b", col.lab="#1d479b", xaxs="i", yaxs="i")
symbols(x / 365.25 * 12, y, circles=z, inches=0.3, bg="#548aee", main=main, xlab=plos.xlab, ylab=plos.ylab, las=1)
#text(x / 365.25 * 12, views, alm$doi, pos=3, offset=0.75, cex=0.5)
par(opar)