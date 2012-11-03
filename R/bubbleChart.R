#' Bubble chart
#'
#' @author Martin Fenner <mfenner@plos.org>

bubblechartp <- function(x, y, z=NULL, xlab=NULL, ylab=NULL, xmax=max(x * 1.1, na.rm = TRUE), ymax=max(y * 1.2, na.rm = TRUE), labels="#1447f2", main=NULL, description=NULL, bubble=1, col.main="#1447f2", col="#666358") {
  
  # Load required libraries
  library(plyr)
  
  # Calculate bubble diameter
  z <- sqrt( z / pi )

  # Use 0 for scatter blot and 1 for bubble chart
  bubble <- 1
  
  # Calculate journal name and color
  if (class(labels) == "numeric") {
    getColor <- function(x) if (x == 1) "#1447f2" else "#c9c9c7"
    colors <- aaply(labels, 1, getColor)
  } else {
    getJournal <- function(doi) {
      plos.journals <- c(pbio="PLoS Biology", 
                       pmed="PLoS Medicine",
                       pone="PLoS ONE",
                       ppat="PLoS Pathogens",
                       pcbi="PLoS Computational Biology",
                       pntd="PLoS Neglected Tropical Diseases",
                       pgen="PLoS Genetics",
                       pctr="PLoS Clinical Trials")
      plos.journals[[substr(doi,17,20)]]
    }
    journals <- aaply(labels, 1, getJournal)
    getColor <- function(doi) {
      plos.journals <- c(pbio="#1ebd21", 
                       pmed="#b526fb",
                       pone="#fda328",
                       ppat="#b526fb",
                       pcbi="#1ebd21",
                       pntd="#b526fb",
                       pgen="#1ebd21",
                       pctr="#b526fb")
      plos.journals[[substr(doi,17,20)]]
    }
    colors <- aaply(labels, 1, getColor)
    #colors <- "#1447f2"
  }

  opar <- par(mai=c(0.5,.75,0.25,0.5), omi=c(0.5,0.5,2,0.5), mgp=c(3,0.75,0), fg="black", cex=1, cex.main=3, cex.lab=2, cex.axis=1.5, col="white", col.main=col.main, col.lab=col)
  plot(x, y, type = "n", xlim=c(0,xmax), ylim=c(0,ymax), xlab=NA, ylab=NA, las=1)
  symbols(x, y, circles=z, inches=exp(bubble * 1.3)/15, bg=colors, xlim=c(0,xmax), ylim=c(0,ymax), xlab=NA, ylab=NA, las=1, add=TRUE)
  title(main=main, outer=TRUE, line=5, adj=0)
  mtext(paste(strwrap(description,width=110), collapse="\n"), side=3, col=col, cex=1.5, outer=TRUE, line=1.5, adj=0)
  mtext(xlab, side=1, col=col.main, cex=2, outer=TRUE, adj=1, at=1)
  mtext(ylab, side=2, col=col.main, cex=2, outer=TRUE, adj=0, at=1, las=1)
  opar <- par(col="black")
  #legend("topleft",legend=levels(journals), inset=c(.05,0), fill=colors, bty="n")
  par(opar)
}