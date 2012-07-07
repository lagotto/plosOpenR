# Heat map from PLoS Article Level Metrics data
# Version 1.0, 07/07/12
# by Martin Fenner, mf@martinfenner.org

# Load required libraries
library(RColorBrewer)

# Load data and sort by descending age
alm <- read.csv("alm_out.csv", header=TRUE)
alm <- alm[order(-alm$age_in_days),]

# Discard columns we don't need, transform into matrix
row.names(alm) <- alm$title
alm <- alm[,c(11,12,8:10,14,7,13,15)]
alm.matrix <- data.matrix(alm)
alm.colnames <- c("Counter","PubMed Central","CrossRef","PubMed","Scopus","Mendeley","CiteULike","Facebook","Twitter")

# Select color palette and labels
pal <- brewer.pal(9,"Blues")
main <- "Michael B. Eisen"
main.color <- "#304345"

# Plot the chart
#opar <- par(mai=c(1.5,1.5,1.5,1.5), mgp=c(4.5,0.75,0), fg="black", cex.main=2, cex.sub=1.25, cex.lab=1, col="white", col.main=label_color, col.lab=label_color, xaxs="i", yaxs="i")
opar <- par(omi=c(0,0,0.2,0), cex.main=1, col.main=main.color, adj=0)
heatmap(alm.matrix, Rowv=NA, Colv=NA, col = pal, scale="column", margins=c(6,35), cexRow=0.5, cexCol=0.5, labCol=alm.colnames, main=main)
par(opar)