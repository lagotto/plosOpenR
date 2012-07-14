# Sparklines from PLoS Article Level Metrics data
# Version 1.0, 07/14/12
# by Martin Fenner, mfenner@plos.org
#

# Load required libraries
library(zoo)

# Load data, produced by almEventFetch script
alm.in <- read.csv("alm_ts_out.csv", header=TRUE)
plos.title <- alm.in[1,11]
plos.published <- as.Date(alm.in[1,12])

# Prepare the chart
png(file="sparklines.png",width=800,height=600, res=72)
par(mfrow=c(2,1),mar=c(0,0,0,0)+0.1,omi=c(0.5,2,0.5,2))

# Loop through each source separately (currently Twitter and CiteULike)
# TODO remove the loop
for(i in c("twitter","citeulike")) {
  # Only use event_time and source column
  alm <- subset(alm.in, alm.in$source == i, select=c("event_time","source"))

  # Convert data to zoo format and aggregate by date
  zoo <- read.zoo(alm, format = "%Y-%m-%d", aggregate=length)

  # Create time interval for 30 days after publication. Fill in missing dates
  dates <- seq(plos.published, by=1, length.out=30)
  empty <- zoo(,dates)
  zoo <- merge(zoo, empty, all=TRUE)
  zoo <- na.fill(zoo, list(0, 0, 0))

  # Convert back to dataframe
  alm <- as.data.frame(zoo)
  alm$date <- as.Date(row.names(alm))
  alm <- subset(alm, select=c("date","zoo"))
  colnames(alm) <- c("date",i)
  row.names(alm) <- NULL
  
  # Set up labels and colors
  plos.labels <- c(citeulike="CiteULike", 
                   twitter="Twitter")
  plos.colors <- c(citeulike="#ad9a27", 
                   twitter="#789aa1")
  plos.sum <- sum(alm[[i]])
  plos.max <- max(alm[[i]])
  plos.label <- paste(plos.labels[i], " (", plos.sum, ")", sep="")
  plos.color <- plos.colors[i]
  
  # Plot the chart
  plot.new()
  plot.window(xlim=c(0, 30), ylim=c(0, 25))
  if(i == "twitter") mtext(plos.title, side=3, line=-2, las=1, cex=2, font=2)
  rect(0:29, 0, 1:30, alm[[i]], col=plos.color, border=NA)
  segments(0,0,30, col=plos.color, lwd=2)
  mtext(plos.label, side=2, at=1, line=1, las=1, cex=1.5, font=2)
}
dev.off()