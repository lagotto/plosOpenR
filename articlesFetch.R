#' Fetch all PLoS articles for a given search string
#'
#' The script searches for PLoS articles using the PLoS Search API and the
#' rplos <https://github.com/ropensci/rplos> library.
#' Please install rplos with Hadley's devtools package, the version on CRAN is outdated.
#' 
#' @author Martin Fenner <mfenner@plos.org>

plossearch <- function(search_string, start_date="2003-08-18", end_date=format(Sys.Date(), "%Y-%m-%d"), limit=1000, key=getOption("PlosApiKey")) {

# Load required libraries
library(rplos)
library(stringr)

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

plos.article_type <- NA
plos.subject_category <- NA

# Construct query and call the PLoS Search API
plos.dates <- paste(" AND publication_date:[", start_date, "T00:00:00Z", " TO ", end_date, "T23:59:59.999Z]", sep="")
plos.article_types <- if(is.na(plos.article_type)) "" else paste(" AND article_type:\"", plos.article_type, "\"", sep="")
plos.subject_categories <- if(is.na(plos.subject_category)) "" else paste(" AND subject_level_1:\"", plos.subject_category, "\"", sep="")
plos.query <- paste(plos.search_string, plos.dates, plos.article_types, plos.subject_categories, " AND doc_type:full", sep="")
plos.search_field <- unique(gsub(":", "", unlist(str_extract_all(plos.search_string, "\\w+:"))))
plos.response_fields <- c("id","journal","publication_date","article_type","title")
if (any(plos.search_field == "financial_disclosure")) {
  plos.response_fields <- c("score","id","journal","publication_date","article_type","title","financial_disclosure")
} else if (any(plos.search_field == "abstract")) {
  plos.response_fields <- c("id","journal","publication_date","article_type","title","abstract")
}
response <- searchplos(terms="*:*", fields=plos.response_fields, toquery=plos.query, limit=limit, key=key)

# Stop if no article was found
stopifnot (nrow(response) > 0)

# Put all authors into one row
author <- paste(response$author, collapse = ", ")
response <- response[1,]
response$author <- author

# Rename id column
names(response)[names(response)=="id"] <- "doi"

# Strip time information from publication_date
response$publication_date <- as.Date(response$publication_date)

# Remove whitespace from financial_disclosure
if ("financial_disclosure" %in% colnames(response)) {

  response$financial_disclosure <- gsub("\n", " ", response$financial_disclosure, fixed=TRUE)
  response$financial_disclosure <- gsub("^\\s+|\\s+$", "", response$financial_disclosure)
  response$financial_disclosure <- gsub("                     ", " ", response$financial_disclosure, fixed=TRUE)
  response$financial_disclosure <- gsub("     ", " ", response$financial_disclosure, fixed=TRUE)
}
response
}