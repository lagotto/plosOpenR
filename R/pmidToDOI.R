#' Return DOIs for a list of pmids
#'
#' The script searches the pmid2DOI service (http://http://www.pmid2doi.org) of the Netherlands Bioinformatics Centre
#' 
#' @author Martin Fenner <mfenner@plos.org>

pmidToDOI <- function(articles, url = 'http://www.pmid2doi.org/rest/json/batch/doi', limit=2000) {
  
  stopifnot (nrow(articles) <= limit)
  
  # Make sure articles is a dataframe with a "pmid" column
  if(class(articles) == "character") {
    articles <- as.data.frame(articles)
    colnames(articles) <- c("pmid")
  } else if(class(articles) == "list") {
    articles <- as.data.frame(unlist(articles))
    colnames(articles) <- c("pmid")
  }
  stopifnot(is.data.frame(articles))
  names(articles)[names(articles)=="PMID"] <- "pmid"
  stopifnot (!is.null(articles$pmid))
  
  # Remove duplicate pmids
  articles <- unique(articles)
  
  # Load required libraries
  library(RJSONIO)
  library(RCurl)
  library (plyr)
  
  # Turn pmid column into JSON array and remove whitespace and quotation marks
  pmids <- toJSON(articles$pmid)
  pmids <- gsub("([[:space:]]|\")", "", pmids)
  
  # Retrieve DOIs, then turn them into dataframe
  response <- getForm(url, pmids=pmids)
  response <- ldply (fromJSON(response), data.frame)
  #response$doi <- as.character(response$doi)
  #response
}