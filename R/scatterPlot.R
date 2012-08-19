#' Scatter plot
#'
#' @author Martin Fenner <mfenner@plos.org>

scatterplotp <- function(x, y, z=NULL, xlab=NULL, ylab=NULL, log="", main=NULL, description=NULL, lowess=FALSE, col="#789aa1") {

  # Load required libraries
  library(stats)
  library(RColorBrewer)

  xmax <- max(x * 1.05)
  ymax <- max(y * 1.05)

  # Add color to dots
  colPal <- col #brewer.pal(9,"Blues")

  # Linear regression
  lmfit <- lm(y ~ x, na.action=na.omit)
  # panel.first=c(abline(lmfit, col="#ff6666", lwd=3))
  
  opar <- par(mai=c(0.5,.75,0.25,0.5), omi=c(0.5,0.5,1.5,0.5), mgp=c(3,0.75,0), fg="black", cex.main=2, cex.lab=1.5, col=col, col.main=col, col.lab=col)
  plot(x, y, log=log, type="p", pch=21, col=col, bg=col, xlim=c(1,xmax), ylim=c(1,ymax), xlab="", ylab="", frame.plot=FALSE, las=1)
  if(lowess) lines(lowess(x,y), col="#a17f78", lwd=3)
  title(main=main, cex.main=2, col.main=col, outer=TRUE, line=4, adj=0)
  mtext(paste(strwrap(description,width=120), collapse="\n"), side=3, col="black", cex=1, outer=TRUE, line=1.5, adj=0, xpd=TRUE)
  mtext(xlab, side=1, col=col, cex=1.25, outer=TRUE, adj=1, at=1)
  mtext(ylab, side=2, col=col, cex=1.25, outer=TRUE, adj=0, at=1, las=1)
  par(opar)
}