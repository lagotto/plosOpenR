#' Bubble chart for PLoS Article Level Metrics
#'
#' @author Martin Fenner, mfenner@plos.org

# Utility functions
today <- format(Sys.Date(), "%Y-%m-%d")

# Load data
alm <- read.csv("alm_out.csv", header=TRUE)
x <- alm$age_in_days
y <- alm$counter + alm$pmc
z <- sqrt( alm$crossref / pi )

# Labels
today <- format(Sys.Date(), "%B %e, %Y")
plos.title <- "Title"
plos.description <- "Description"
plos.xlab <- "Months"
plos.ylab <- "Cumulative Views"
plos.color <- "#789aa1"
  
# Plot the chart. Results are saved in the "data-charts" subdirectory
plos.data_charts <- "data-charts"
plos.pdf <- paste(plos.data_charts, "/", "bubbblechart", "_", today, ".pdf", sep="")
pdf(file=plos.pdf, width=8, height=6, title=plos.title, useDingbats=FALSE)

opar <- par(mai=c(0.5,.75,0,0.5), omi=c(0.5,0.5,1.5,0.5), mgp=c(2,0.75,0), fg="black", cex.main=2, cex.lab=1.5, col="white", col.main=plos.color, col.lab=plos.color, xaxs="i", yaxs="i")
symbols(x / 365.25 * 12, y, circles=z, inches=0.25, bg=plos.color, xlab=NA, ylab=NA, las=1)
title(main=plos.title, cex.main=2, outer=TRUE, line=4, adj=0)
mtext(paste(strwrap(plos.description,width=90), collapse="\n"), side=3, col="black", outer=TRUE, line=1.5, adj=0)
mtext(plos.xlab, side=1, col=plos.color, cex=1.25, outer=TRUE, adj=1, at=1)
mtext(plos.ylab, side=2, col=plos.color, cex=1.25, outer=TRUE, adj=0, at=1, las=1)
par(opar)
dev.off()