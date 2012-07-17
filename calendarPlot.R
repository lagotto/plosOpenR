# Calendar plots from PLoS Article Level Metrics data
# Version 1.0, 07/13/12
# by Martin Fenner, mfenner@plos.org

# Load required libraries
library(zoo)
library(openair)

# Load data, produced by almEventFetch script
alm <- read.csv("alm_ts_out.csv", header=TRUE)
title <- alm[1,11]

plos.year <- "2012"
plos.source <- "twitter"

# Only use tweets, and only use event_time and source column
alm <- subset(alm, alm$source == plos.source, select=c("event_time","source"))

# Convert data to zoo format and aggregate by date
zoo <- read.zoo(alm, format = "%Y-%m-%d", aggregate=length)

# Add one empty date per month to display the whole year
dates <- seq(as.Date(paste(plos.year, "01","01", sep="-")), as.Date(paste(plos.year, "12","01", sep="-")), by="months")
empty <- zoo(,dates)
zoo <- merge(zoo, empty, all=TRUE)

# Convert back to dataframe
alm <- as.data.frame(zoo)
alm$date <- as.Date(row.names(alm))
alm <- subset(alm, select=c("date","zoo"))
colnames(alm) <- c("date",plos.source)
row.names(alm) <- NULL

# Plot calendar
calendarPlot(alm, pollutant=plos.source, year=plos.year, annotate="value", main=title, limits = c(0, 50), cex.lim=c(1,1))