require(zoo)
require(plyr)

#data originating from , prepared before in oo calc as csv

my.plos <- read.csv("plosalm.csv",header=T,sep=",")

tt <- ddply(my.plos,.(Publication.Date,Journal), nrow)

date <- strptime(tt$Publication.Date,format="%d.%m.%Y")

year <- date$year + 1900

my.data <- cbind(tt,date, year)

#table
my.tab <- as.data.frame(tapply(my.data$V1, my.data[,c("Journal","year")],sum))

sum.journal <- rowSums(my.tab, na.rm=T)
my.tab <- cbind(my.tab,sum.journal)

sum.year <- colSums(my.tab, na.rm=T)
my.tab <- rbind(my.tab,sum.year)

#export as html table 
require("xtable")
my.tab.x <- xtable(my.tab)
digits(my.tab.x) <- 0
print(my.tab.x, type="html", file="summaryPLoS.html")

require(zoo)
#plos one
my.plos <- subset(my.data, Journal == "PLoS ONE")

#as zoo object to monthly summary
z <- zoo(my.plos$V1, my.plos$date)

t.z <- aggregate(z, as.yearmon, sum)

#time series object
ts.q <- ts (t.z, start=c(2006,12), frequency = 12)

#Holt-Winter Distribution
ts.holt <- HoltWinters(ts.q)

forecast <- predict(ts.holt, n.ahead = 21, prediction.interval = T, level = 0.95)

plot(ts.holt,forecast, frame.plot=F, xlim=c(2007,2014), ylim=c(0,4500), 
     main="Holt-Winters filtering PLoS ONE contributions")
