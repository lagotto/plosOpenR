# Density plots from PLoS Article Level Metrics data
# Version 1.0, 07/07/12
# by Martin Fenner, mf@martinfenner.org

# Load data
alm <- read.csv("alm_out.csv", header=TRUE)

# Labels
colnames <- dimnames(alm)[[2]]
plot.color <- "#789aa1"
plos.source <- "mendeley"
main <- "PLoS Biology 2009"
plos.xlab <- "Mendeley Readers and Groups"
plos.ylab <- "Probability"

# Plot the chart
opar <- par(mai=c(1.5,1.5,1.5,1.5), mfrow=c(1, 1),  mgp=c(4,1.5,0.5), fg="black", cex.main=2, cex.sub=1.25, cex.lab=1.5, col="white", col.main=label_color, col.lab=label_color, xaxs="i", yaxs="i")
d <- density(alm[,plos.source])
plot(d, type="n", main=main, xlab=plos.xlab, ylab=plos.ylab,ylim=c(0,.025), frame.plot=FALSE)
polygon(d, col=plot.color, border=NA)
par(opar)