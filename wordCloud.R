# Word cloud using titles from a list of articles
# Version 1.0, 07/07/12
# by Martin Fenner, mf@martinfenner.org

# Load required libraries
library(tm)
library(wordcloud)
library(RColorBrewer)

# Load data
alm <- read.csv("alm_out.csv", header=TRUE)
alm.corpus <- Corpus(DataframeSource(alm["title"]))
alm.stopwords <- c("\u0096","\u0097","italic","sup","The","not","Not","can","Can","are","Are","using","Using","reveals","Reveals","identifies","Identifies","New","novel","Novel","cell","Cell","analysis","Analysis","specific","Specific","Role","Effect","Effects","effects","low","Rapid","data","High","Low","association","two","Potential")

# Clean up corpus
alm.corpus <- tm_map(alm.corpus, removeWords, alm.stopwords)
alm.corpus <- tm_map(alm.corpus, function(x) removeWords(x, stopwords("english")))
alm.corpus <- tm_map(alm.corpus, function(x) removePunctuation(x))

tdm <- TermDocumentMatrix(alm.corpus)
m <- as.matrix(tdm)
v <- sort(rowSums(m),decreasing=TRUE)
d <- data.frame(word = names(v),freq=v)
pal <- brewer.pal(9, "Blues")
pal <- pal[-(1:2)]

# Plot the chart
wordcloud(d$word,d$freq, scale=c(3,.1),min.freq=2,max.words=250, random.order=FALSE, rot.per=.2, colors=pal)