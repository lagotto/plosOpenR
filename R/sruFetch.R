#' Fetch DOIs for journals via SRU version 1.1 <http://www.loc.gov/standards/sru/> from local repositories. 
#' MODS-XML is required as default format.
#Najko Jahn v 0.0.1 <najko.jahn@uni-bielefeld.de>
#
#' @import XML RCurl
#' @param year publishing year (format yyyy)
#' @params sru.base Base-URL of SRU Interface
#' @params issn Journal ISSN
#' @example \dontrun{fetchSRU(year = 2011, sru.base = "http://pub.uni-bielefeld.de/sru", issn = "1932-6203")}
#' Returns data.frame with Repository name, local record id, publishing year and doi, id to be further passed.
#' @author <najko.jahnuni-bielefeld.de>

fetchSRU <- function(year = NA, sru.base = NA, issn = NA) {
  #data.frame to be returned
  my.data <- data.frame()
  
  #CURL Option
  
  ch <- getCurlHandle()
  
  curlSetOpt(curl = ch,
             ssl.verifypeer = FALSE)
  
  #arguments for API call as list
  .args <- list()
  .args$version <- "1.1"
  .args$operation <- "searchRetrieve"
  .args$maximumRecords <- "250"
  .args$query <- paste('issn=', issn, ' AND ', 'publishingYear=', year, sep="")
  
  for (i in unlist(sru.base)) {
    doc <- xmlTreeParse(getForm(i, .params = .args), useInternal=T)
    maxrecs <- as.numeric(xpathSApply(doc, "//r:numberOfRecords",
                                      namespaces = (c(r="http://www.loc.gov/zing/srw/")), xmlValue))
    
    id <- c()
    year <- c()
    doi <- c()
    
    for (j in seq(1, maxrecs, by=250)) {
      .args$startRecord <- j
      doc <- xmlTreeParse(getForm(i, .params = .args), useInternal=T)
      id.tmp <- xpathSApply(doc,"//r:recordInfo//r:recordIdentifier", 
                            namespaces= (c(r="http://www.loc.gov/mods/v3")) ,xmlValue)
      year.tmp <- xpathSApply(doc,"//r:dateIssued",
                              namespaces= (c(r="http://www.loc.gov/mods/v3")) ,xmlValue)
      doi.tmp <- xpathSApply(doc,"//r:identifier[@type='doi']",
                             namespaces= (c(r="http://www.loc.gov/mods/v3")),xmlValue)
      id <- c(id, id.tmp)
      year <- c(year,year.tmp)
      doi<- c(doi,doi.tmp)
      
      repo <- rep(i, times=length(id))
      my.data.tmp <- data.frame(repo, id, year, doi)
    }
    my.data <- rbind(my.data, my.data.tmp) 
  }
  return(my.data)
  
}
