#' Wrapper to retrieve historical record of crossref citation counts as data.frame (cumulative).
#' @import rplos RJSONIO RCurl
#' @param doi digital object identifier for an article in PLoS Journals
#' @param API APi-Key
#' @author Najko Jahn <najko.jahn@uni-bielefeld.de>

history.crossref <- function (doi = NA, api.key = NA) {

tt <- almplosallviews(doi, source_ = "crossref", downform='json', 
                      events = 0, history = 1, key = api.key)

my.data <- data.frame(do.call("rbind", tt$article$source[[1]]$histories))
  
return(my.data)

}