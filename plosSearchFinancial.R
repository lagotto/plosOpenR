# Fetch all PLoS articles for given Research Funding Scheme
# Version 1.0, 07/10/12
# by Najko Jahn, najko.jahn@uni-bielefeld.de
#
# The function searches for PLoS articles using the PLoS Search API
# <http://api.plos.org/search>
#
#It returns a data.frame containing the variables doi, financial_disclosure, publication_date.article_type, PLoS journal
#
#Acknowledgement: Useful hints provided by Martin Fenner <https://github.com/mfenner> and rplos <https://github.com/ropensci/rplos>  
#
#@import XML, RCurl
#@param date.range vector start and end date (format yyyy-mm-dd)
#@params funder name of funder or funding scheme
#@params PLoS Api Key

require(XML)

plosSearchFinancial <- function (date.range = NA, funder = NA, apiKey = NA, sleep = NA, 
                                 url = "http://api.plos.org/search") {
  #data.frame to be returned
  my.data <- data.frame()
  #date range from vector to be passed to function call
  get.range <- paste("[",date.range[1],"T00:00:00Z TO ", date.range[2],"T23:59:59:99Z]",sep="")
  
  #arguments for API call as list
  .args <- list()
  if(!is.na(get.range)) {
    .args$q  <- paste("financial_disclosure:",funder," AND ", get.range, sep="") 
  } else {
    .args$q <- paste("financial_disclosure:", funder, sep = "")
  }
  .args$fl <- paste("id","financial_disclosure","publication_date","article_type","journal", sep=",")
  .args$api_key <- apiKey
  
  ###looping over results
  
  #delineating range
  
  doc <- xmlTreeParse(getForm(url, .params = .args), useInternal=T)
  
  getnumrecords <- as.numeric(xpathSApply(doc, "//result//@numFound"))
  
  #loop over range 
  for ( i in seq(0,getnumrecords, by = 50 )) {
    .args$rows = 50
    .args$start = i

    Sys.sleep(sleep)
    
    doc <- xmlTreeParse(getForm(url, .params = .args), useInternal=T)
    
    financial_disclosure <- xpathSApply(doc, "//result//doc//str[@name='financial_disclosure']",xmlValue)
    #clean
    financial_disclosure <- gsub("\n", " ", financial_disclosure, fixed=TRUE)
    financial_disclosure <- gsub("^\\s+|\\s+$", "", financial_disclosure)
    
    doi <- xpathSApply(doc, "//result//doc//str[@name='id']",xmlValue)
    
    publication_date <- xpathSApply(doc, "//result//doc//date[@name='publication_date']",xmlValue)
    
    article_type <- xpathSApply(doc, "//result//doc//str[@name='article_type']",xmlValue)
    
    journal <- xpathSApply(doc, "//result//doc//str[@name='journal']",xmlValue)
    
    data.tmp <- data.frame(doi, financial_disclosure, publication_date, article_type, journal)
    
    my.data <- rbind(my.data, data.tmp)    
  }
  
  return(my.data)
  
}
