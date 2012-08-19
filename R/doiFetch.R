#' Fetch all PLoS articles for a given search string
#'
#' The script searches for PLoS articles using the PLoS Search API and the
#' rplos <https://github.com/ropensci/rplos> library.
#' Please install rplos with Hadley's devtools package, the version on CRAN is outdated.
#' 
#' @author Martin Fenner <mfenner@plos.org>

doiFetch <- function(articles, fields=c("id","journal","publication_date","article_type","title","author"), key=getOption("PlosApiKey")) {

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
  
  # Load required libraries
  library(rplos)
  library(stringr)
  
  results <- data.frame()
  
  # Loop through all provided DOIs
  for (i in 1:nrow(articles))  {
    article <- articles[i,]
    doi <- if(ncol(articles) > 1 ) article$doi else article
    # Calling the PLoS ALM API. Waiting 10 sec before calling the API again
    response <- searchplos(terms="*:*", fields=fields, toquery=paste("id:",doi,sep=""), key=key)
    
    # Put all authors into one row
    author <- paste(response$author, collapse = ", ")
    response <- response[1,]
    response$author <- author
    
    # Next if no article was found
    if (!nrow(response) > 0) next
    
    # Rename id column
    names(response)[names(response)=="id"] <- "doi"
    
    # Clean up title
    article.title <- gsub("</?(italic|sub|sup)>", "", response$title)
    article.title <- gsub("(“|”|\")", "'", article.title)
    article.title <- iconv(article.title, from = "latin1", to = "UTF-8")
    article.title <- gsub("\n", " ", article.title, fixed=TRUE)
    article.title <- gsub("                    ", "", article.title, fixed=TRUE)
    article.title <- str_trim(article.title)
    response$title <- article.title
    
    results <- rbind(results, response)
  }
  results
}