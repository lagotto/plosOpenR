# Bubble chart from PLoS Article Level Metrics data
# Version 1.0, 07/05/12
# by Martin Fenner, mf@martinfenner.org

# Load data
alm <- read.csv("alm_out.csv", header=TRUE)
x <- alm$age_in_days
y <- alm$counter + alm$pmc
z <- sqrt( alm$crossref / pi )

# Labels
main <- "2009 PLoS Biology Articles"
today <- format(Sys.Date(), "%B %e, %Y")
sub <- sprintf("PLoS Article Level Metrics Report (%s)", today)
plos.xlab <- "Months"
plos.ylab <- "Cumulative Views"
main_color <- "#789aa1"
label_color <- "#304345"
  

# Plot the chart
opar <- par(mai=c(1.5,1.5,1.5,1.5), mgp=c(4.5,0.75,0), fg="black", cex.main=2, cex.sub=1.25, cex.lab=1.5, col="white", col.main=label_color, col.lab=label_color, xaxs="i", yaxs="i")
symbols(x / 365.25 * 12, y, circles=z, inches=0.25, bg=main_color, main=main, xlab=plos.xlab, ylab=plos.ylab, las=1)
#text(x / 365.25 * 12, views, alm$doi, pos=3, offset=0.75, cex=0.5)
par(opar)