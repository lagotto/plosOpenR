#' Initial considerations for generating institutional co-authorship networks plottet against maps
#' Excellent hint for mapping geographic connections:
#' <http://flowingdata.com/2011/05/11/how-to-map-connections-with-great-circles/>


require(plyr)
require(ggmap)
require(RJSONIO)
require(RCurl)
require(igraph)
require(maps)
require(geosphere)


#fetch affiliations out of dta.frame containing PLOS DOIs, example FP7 Collaborative HIV and Anti-HIV Drug Resistance Network (GrantID = 223131)

my.data <- read.csv("./data-alm/fp7TM.csv",header=T,sep=",")

ttt <- melt(my.data,id.vars=c("doi","publication_date","article_type"),
            c("grantID1","grantID2","grantID3","grantID4"))

tt <- na.omit(ttt)

my.data <- subset(tt, value == 223131)

my.plos <- affiliateFetch(articles = my.data, key ="") #enter api.key

#get Geo-Coordinates, for latlon either geocodeFetch.R (Yahoo) or geocode function ggmap (Google maps)

geoPlos <- geocode(as.character(unlist(my.plos$affiliate)))

my.plos.latlon <- cbind(my.plos,geoPlos)

#exclude na or fix manually (in this case Department+of+Infectious+Diseases,+the+Sahlgrenska+Academy+at+the+University+of+Gothenburg,+Gothenburg,+Sweden omitted)

my.plos.latlon <- na.omit(my.plos.latlon)

#get edgelist

edge.compl <- data.frame()

for (i in unlist(my.plos.latlon$doi)) {
  
  tmp <- subset(my.plos.latlon, doi == i)
  
  #obtain two-mode network  
  mat <- table(tmp$doi, tmp$affiliate)
  
  #obtain one-mode perspective institution
  mat.t <- t(mat)%*%(mat)
  
  #set diagonal to 0 in order to exclude self-links
  diag(mat.t) <- 0
  
  #convert to edge list via igraph  
  my.graph <- graph.adjacency(mat.t, diag=F, mode= "undirected") 
  
  my.edge <- get.edgelist(my.graph)
  
  #store relation to paper as attribute (DOI)
  doi <- rep(i, times=nrow(my.edge))
  
  my.edge <- cbind(my.edge,doi)
  
  edge.compl <- rbind(edge.compl, my.edge)
  
}

#plot

#prepare color palette

pal <- colorRampPalette(c("#333333", "white", "#1292db"))

colors <- pal(length(unique(unlist(edge.compl$doi))))

doi <- as.character(unique(unlist(edge.compl$doi)))

my.color.palette <- data.frame(colors, doi)

edge.compl <- merge(edge.compl, my.color.palette, by = "doi")

#plot map

png("./examples/affiliateMAP.png")

map("world",col="#191919", fill=TRUE, bg="#000000", lwd=0.05, xlim = (c(-130,32)), 
    ylim = c(20,69))

#plot vertices, grouped by paper

for (i in 1 : nrow(edge.compl)) {
  tmp.1 <- subset(my.plos.latlon, affiliate %in% unlist(edge.compl[i,2]))
  
  tmp.2 <- subset(my.plos.latlon, affiliate %in% unlist(edge.compl[i,3]))
  
  inter <- gcIntermediate(c(tmp.1$lon[1], tmp.1$lat[1]), c(tmp.2$lon[1], tmp.2[1,]$lat[1]),
                          n=100, addStartEnd=TRUE)
  
  lines(inter, col=as.character(edge.compl[i,4]), lwd=0.2)
  
}

dev.off()