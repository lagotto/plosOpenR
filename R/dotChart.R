#' Dot chart
#'
#' @author Martin Fenner <mfenner@plos.org>

dotchart <- function(x1, x2, labels, xlab=NULL, x3="", x3lab=NULL, main=NULL, description=NULL, col="#789aa1") {

  # Load required libraries
  library(Hmisc)
  library(stringr)

  xmax <- max(x2) * 1.05
  labels <- str_sub(labels, start=1, end=90)
  cex.labels <- 0.75

  opar <- par(mai=c(.5,0,.75,0.5), omi=c(.5,.5,.5,.5), fin=c(10,7.5), lty=0)
  dotchart2(x1, labels=labels, cex.labels=cex.labels, auxdata=x3, auxtitle=x3lab, dotsize=1, lty=3, pch=1, xlim=c(0,xmax), reset.par=TRUE)
  dotchart2(x2, labels=labels, cex.labels=cex.labels, dotsize=1, pch=19, xlim=c(0,xmax), add=TRUE)

  title(main=main, cex.main=2, col.main=col, outer=TRUE, line=0, adj=0)
  mtext(paste(strwrap(description,width=120), collapse="\n"), side=3, col="black", cex=1, outer=TRUE, line=-2.75, adj=0, xpd=TRUE)
  mtext(xlab, side=1, col=col, cex=1, outer=TRUE, line=-.5, adj=1)
  par(opar)
}