#' Fetch Article Level Metrics from PLOS
#' @import rplos stringr plyr
#' @param articles list of DOIs (dataframe)
#' Provide a dataframe with at least one DOI column. The function calls the 
#' PLOS ALM API and adds the response to the input dataframe
#' @examples \dontrun{
#' almFetch(articles)
#' }
#' @author Martin Fenner <mfenner@plos.org>

almFetch <- function(articles, key=getOption("PlosApiKey")) {
  
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
      article.title <- iconv(article.title, from = "latin1", to = "UTF-8")
      article.title <- gsub("\n", " ", article.title, fixed=TRUE)
      article.title <- gsub("                    ", "", article.title, fixed=TRUE)
      article.title <- str_trim(article.title)
      result <- c(result, list(title=article.title))
    }
    
    lst <- list()
    
    # Add event_counts from sources. We will not use all sources, and need special parsing for some sources.
    for (source in response$article$source) {
      source.name <- tolower(source$source)
      if (source.name == "crossref" ||
        source.name == "scopus" ||
        source.name == "citeulike" ||
        source.name == "twitter") {
        lst[source.name] <- source$count
      } else if (source$source == "PubMed Central") {
        lst["pubmed"] <- source$count
      } else if (source.name == "counter") {
        pdf_views <- sum(as.numeric(sapply(source$events, `[[`, "pdf_views")))
        html_views <- sum(as.numeric(sapply(source$events, `[[`, "html_views")))
        xml_views <- sum(as.numeric(sapply(source$events, `[[`, "xml_views")))
        lst["counter_pdf"] <- pdf_views
        lst["counter_html"] <- html_views
        lst["counter_xml"] <- xml_views
        lst["counter"] <- source$count
      } else if (source$source== "PubMed Central Usage Stats") {
        views <- source$citations[[1]]$citation$views
        pdf <- sum(as.numeric(sapply(source$events, `[[`, "pdf")))
        html <- sum(as.numeric(sapply(source$events, `[[`, "full-text")))
        lst["pmc_pdf"] <- pdf
        lst["pmc_html"] <- html
        lst["pmc"] <- source$count
      } else if (source$source == "Research Blogging") {
        lst["researchblogging"] <- source$count
      } else if (source.name == "facebook") {
        if (source$count > 0) {
          lst["facebook_shares"] <- sum(as.numeric(sapply(source$events, `[[`, "share_count")))
          lst["facebook_likes"] <- sum(as.numeric(sapply(source$events, `[[`, "like_count")))
          lst["facebook_comments"] <- sum(as.numeric(sapply(source$events, `[[`, "comment_count")))
          lst["facebook_clicks"] <- sum(as.numeric(sapply(source$events, `[[`, "click_count")))
          lst["facebook"] <- source$count
        } else {
          lst["facebook_shares"] <- 0
          lst["facebook_likes"] <- 0
          lst["facebook_comments"] <- 0
          lst["facebook_clicks"] <- 0
          lst["facebook"] <- 0
        }
      } else if (source.name == "mendeley") {
        readers <- if(is.null(source$events)) 0 else source$events$stats$readers
        groups <- if(is.null(source$events) || is.null(source$events$groups)) 0 else length(source$events$groups)
        lst["mendeley_readers"] <- readers
        lst["mendeley_groups"] <- groups
        lst["mendeley"] <- source$count
      } else {
        next
      }
    }
    result <- c(result, lst)
    alm <- rbind(alm, data.frame(result))
  }
  
  # Merge with input dataframe and return the result
  alm <- merge(articles, alm, by="doi", all.x=TRUE)
}