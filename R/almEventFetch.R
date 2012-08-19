
#' Fetch Article Level Metrics Events from PLOS
#' In contrast to the almFetch script, this script collects metrics that have event-based information,
#  i.e. a date/time, URL and author for every event. This information can be used for different visualizations,
#  e.g. time series, or mapping. Currently the PLoS ALM API provides this information only for CiteULike and Twitter.
#' @import rplos stringr plyr
#' @param articles list of DOIs (dataframe)
#' Provide a dataframe with at least one DOI column. The function calls the 
#' PLOS ALM API and adds the response to the input dataframe
#' @examples \dontrun{
#' almFetch(articles)
#' }
#' @author Martin Fenner <mfenner@plos.org>

almEventFetch <- function(articles, key=getOption("PlosApiKey")) {
  
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
  library(plyr)
  suppressPackageStartupMessages(library(googleVis))
  
  # Parse journal name from DOI unless we know the name already
  if (is.null(articles$journal)) {
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
    articles$journal <- daply(articles, "doi", getJournal)
  }
  
  alm <- data.frame()
  
  # Loop through all provided DOIs
  for (i in 1:nrow(articles))  {
    article <- articles[i,]
    # Calling the PLoS ALM API. Waiting 10 sec before calling the API again.
    response <- almplosallviews(article$doi, events=1, downform='json', sleep=10, key = key)
    
    # Start with the DOI, needed for merging
    result <- list(doi=article$doi)
    
    # Add PMID if it exists
    article.pmid <- if (is.null(response$article$pub_med)) NA else as.numeric(response$article$pub_med)
    result <- c(result, list(pmid=article.pmid))
    
    # Parse publication date unless we know it already
    if (is.null(article$publication_date)) {
      article.publication_date <- as.Date(response$article$published)
      result <- c(result, list(publication_date=article.publication_date))
    }
    
    # Parse title from response unless we know it already
    if (is.null(article$title)) {
      article.title <- gsub("</?(italic|sub|sup)>", "", response$article$title)
      article.title <- gsub("(“|”|\")", "'", article.title)
      article.title <- iconv(article.title, from = "latin1", to = "UTF-8")
      article.title <- gsub("\n", " ", article.title, fixed=TRUE)
      article.title <- gsub("                    ", "", article.title, fixed=TRUE)
      article.title <- str_trim(article.title)
      result <- c(result, list(title=article.title))
    }
    
    # Add events from sources that support them. Discard the other information. 
    for (source in response$article$source) {
      source.name <- tolower(source$source)
      if (source.name == "citeulike" && !is.null(source$events)) {
        # TODO remove loop
        for (event in source$events) {
          lst <- list()
          lst["event_time"] <- event$event["post_time"]
          lst["source"] <- source.name
          lst["event_id"] <- NA
          lst["event_type"] <- if (is.null(event$event["username"])) "group_bookmark" else "bookmark"
          lst["event_user"] <- NA
          lst["event_url"] <- event["event_url"]
          lst["event_text"] <- "none"
          alm <- rbind(alm, data.frame(c(lst, result)))
        }
      } else if (source.name == "twitter" && !is.null(source$events)) {
        # TODO remove loop
        for (event in source$events) {
          lst <- list()
          # The PLoS API unfortunately returns two different time formats for Twitter, first one is RFC 2822
          event_time <- event$event["created_at"]
          if (substr(event_time,4,4) == ",") {
            lst["event_time"] <- strftime(strptime(event_time, "%a, %d %b %Y %H:%M:%S %z"))
          } else {
            lst["event_time"] <- strftime(strptime(event_time, "%a %b %d %H:%M:%S %z %Y"))
          }
          lst["source"] <- source.name
          lst["event_id"] <-  event$event["id"]
          lst["event_type"] <- "tweet"
          lst["event_user"] <- event$event["user"]
          lst["event_url"] <- event["event_url"]
          lst["event_text"] <- event$event["text"]
          alm <- rbind(alm, data.frame(c(lst, result)))
        }
      } else {
        next
      }
    }
  }
  alm$event_time <- as.POSIXlt(alm$event_time, format='%Y-%m-%d %H:%M:%S')
  alm <- alm[order(alm$event_time),]
}