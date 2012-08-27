#' Wrapper to retrieve th monthly record of Usage counts (COUNTER) as data.frame (cumulative).
#' Returns html views, xml views, pdf views and date. 
#' @import rplos RJSONIO RCurl chron
#' @param doi digital object identifier for an article in PLoS Journals
#' @param API APi-Key
#' @author Najko Jahn <najko.jahn@uni-bielefeld.de>

event.counter <- function (doi = NA, api.key = NA) {
  
  tt <- almplosallviews(doi, source_ = "counter", downform='json', 
                        events = 1, history = 0, key = api.key)
  
  my.data <- data.frame(do.call("rbind", tt$article$source[[1]]$events))
  
  #converting month,year into date object 
  
  my.date <- as.Date(Sys.time(), format="%Y-%m-%d")

  published <- as.Date(unlist(tt$article$published), format ="%Y-%m-%d")
  
  seq.date <- seq.dates(julian(published),julian(my.date),by= "month")
  
  my.data.tmp <- data.frame(my.data[1: length(seq.date),
                                    c("month","year","pdf_views","xml_views","html_views")],seq.date)
  
  #values to numeric
  my.data.tmp$html_views <- as.numeric(levels(my.data.tmp$html_views))[my.data.tmp$html_views]
  my.data.tmp$pdf_views <- as.numeric(levels(my.data.tmp$pdf_views))[my.data.tmp$pdf_views]
  my.data.tmp$xml_views <- as.numeric(levels(my.data.tmp$xml_views))[my.data.tmp$xml_views]
  
  return(my.data.tmp)
  
}