#' Return affiliation information for a list of DOIs
#'
#' The script searches for PLoS articles using the PLoS Search API and the
#' rplos <https://github.com/ropensci/rplos> library.
#' Please install rplos with Hadley's devtools package, the version on CRAN is outdated.
#' 
#' @author Martin Fenner <mfenner@plos.org>

affiliateFetch <- function(articles, authors="all", limit=1000, sleep = 0, key=getOption("PlosApiKey")) {
  
  stopifnot (nrow(articles) <= limit)
  
  # Make sure articles is a dataframe with a "doi" column
  if(class(articles) == "character") {
    articles <- as.data.frame(articles)
    colnames(articles) <- c("doi")
  } else if(class(articles) == "list") {
    articles <- as.data.frame(unlist(articles))
    colnames(articles) <- c("doi")
  }
  stopifnot(is.data.frame(articles))
  names(articles)[names(articles)=="DOI"] <- "doi"
  stopifnot (!is.null(articles$doi))
  
  # Remove duplicate DOIs
  articles <- unique(articles)
  
  # Load required libraries
  library(rplos)
  library(stringr)
  
  # Fields to return
  fields <- c("id","affiliate")
  
  results <- data.frame()
  
  # Loop through all provided DOIs
  for (i in 1:nrow(articles)) {
    Sys.sleep(sleep)
    article <- articles[i,]
    doi <- if(ncol(articles) > 1 ) article$doi else article
    # Calling the PLoS ALM API. Waiting 10 sec before calling the API again
    response <- searchplos(terms="*:*", fields=fields, toquery=paste("id:",doi,sep=""), key=key)
    
    # Next if no article was found
    stopifnot (nrow(response) > 0)
    
    # Rename id column
    names(response)[names(response)=="id"] <- "doi"
    
    # Only return affiliation of first, last or all other others
    if (authors == "first") {
      response <- response[1,]
    } else if (authors == "last") {
      response <- response[nrow(response),]
    } else if (authors == "other") { response <- if (nrow(response) > 2) response[2:nrow(response)-1,] else next }
    
    results <- rbind(results, response)
  }
  results
}