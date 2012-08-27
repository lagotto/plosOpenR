#' Fetch all PLoS articles for a given search string
#'
#' The script searches for PLoS articles using the PLoS Search API and the
#' rplos <https://github.com/ropensci/rplos> library.
#' Please install rplos with Hadley's devtools package, the version on CRAN is outdated.
#' 
#' @author Martin Fenner <mfenner@plos.org>

articlesFetch <- function(search_string=NULL, start_date="2003-08-18", end_date=format(Sys.Date(), "%Y-%m-%d"), limit=1000, article_type=NULL, subject_category=NULL, key=getOption("PlosApiKey")) {

  # Load required libraries and functions
  library(rplos)
  library(stringr)
  library(plyr)
  source("R/cleanText.R",chdir=TRUE)

  # Define query, possible fields to search in are listed at <http://api.plos.org/solr/search-fields/>, including
  # author
  # editor
  # affiliate
  # journal
  # financial_disclosure
  # article_type
  # abstract
  #
  # affiliate can be used to search for institutions
  # financial_disclosure is helpful to search for funding information
  # start_date and end_date should be in format yyyy-mm-dd
  # Using quotes around the search term in SOLR means AND, important for author names
  # The PLoS Search API uses Lucene syntax, more information at
  # <http://lucene.apache.org/core/3_6_0/queryparsersyntax.html>
  # Use doc_type:full (undocumented) to not return component DOIs

  # Construct query and call the PLoS Search API
  dates <- paste(" AND publication_date:[", start_date, "T00:00:00Z", " TO ", end_date, "T23:59:59.999Z]", sep="")
  article_types <- if(is.null(article_type)) "" else paste(" AND article_type:\"", article_type, "\"", sep="")
  subject_categories <- if(is.null(subject_category)) "" else paste(" AND subject_level_1:\"", subject_category, "\"", sep="")
  query <- paste(search_string, dates, article_types, subject_categories, " AND doc_type:full", sep="")
  fields <- c("id","journal","publication_date","article_type","title")
  search_field <- unique(gsub(":", "", unlist(str_extract_all(search_string, "\\w+:"))))
  if (any(search_field == "financial_disclosure")) {
    fields <- c(fields,"financial_disclosure")
  } 
  if (any(search_field == "abstract")) {
    fields <- c(fields,"abstract")
  }
  response <- searchplos(terms="*:*", fields=fields, toquery=query, limit=limit, key=key)

  # Stop if no article was found
  stopifnot (nrow(response) > 0)
  
  # Rename id column
  names(response)[names(response)=="id"] <- "doi"

  # Format publication_date
  response$publication_date <- as.Date(response$publication_date)
  
  # Clean title
  #response$title <- aaply(response$title, 1, cleanText)

  response
}