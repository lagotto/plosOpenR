# Exploring the collaboration network of PLoS papers and projects. The script obtains a two-mode matrix, calculates the respective one-mode
# perspective. Forms the basis for the application of SNA methods.
#' @import plyr sna
#' @author Najko Jahn

# data input 
my.data <- read.csv("./data-alm/fp7TM.csv",header=T,sep=",")

ttt <- melt(my.data,id.vars=c("doi","publication_date","article_type"),
            c("grantID1","grantID2","grantID3","grantID4"))

tt <- na.omit(ttt)

### calculationg two-mode

my.mat <- table(as.character(tt$doi),as.character(tt$value))

### project perspectiv one -mode
mat.t <- t(my.mat)%*%(my.mat)

### explorative plot, excludes isolates

gplot(mat.t, gmode="graph",
      mode="kamadakawai",
      vertex.col="orangered2",    
      diag=F,
      vertex.cex=sqrt(diag(mat.t))*0.6,
      vertex.lty = 1,
      vertex.sides = 64,
      vertex.border="white",
      edge.col="grey",
      displayisolates=F)

#my.graph <- graph.data.frame(my.data[,c(1,5)])
