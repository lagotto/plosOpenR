# Fetch all PLoS articles for a given search string
# Version 1.0, 07/08/12
# by Martin Fenner, mf@martinfenner.org
#
# The script searches for PLoS articles using the PLoS Search API and the
# rplos <https://github.com/ropensci/rplos> library.

# Load required libraries
library(rplos)

# Load PLoS API key from .rProfile file
plos.api_key <- getOption("PlosApiKey")

# Utility functions
today <- format(Sys.Date(), "%Y-%m-%d")

# Define query, possible plos.fields are listed at <http://api.plos.org/solr/search-fields/>
# Examples: author, editor, affiliate, journal, financial_disclosure, article_type
# affiliate can be used to search for institutions
# financial_disclosure is helpful to search for funding information
# start_date and end_date should be in format yyyy-mm-dd
# The PLoS Search API uses Lucene syntax, more information at
# <http://lucene.apache.org/core/3_6_0/queryparsersyntax.html>
# Use doc_type:full (undocumented) to not return composite DOIs?
plos.search_field <- c("title")
plos.search_string <- c("DNA Barcoding")
plos.start_date <- c("2011-08-18")
plos.end_date <- today
plos.article_type <- NA
plos.subject_category <- NA

# Construct query and call the PLoS Search API
plos.dates <- paste(" AND publication_date:[", plos.start_date, "T00:00:00Z", " TO ", plos.end_date, "T23:59:59.999Z]", sep="")
plos.article_types <- if(is.na(plos.article_type)) "" else paste(" AND article_type:\"", plos.article_type, "\"", sep="")
plos.subject_categories <- if(is.na(plos.subject_category)) "" else paste(" AND subject_level_1:\"", plos.subject_category, "\"", sep="")
plos.query <- paste(plos.search_field, ":\"", plos.search_string, "\"", plos.dates, plos.article_types, " AND doc_type:full", sep="")
if (plos.search_field == "journal" || plos.search_field == "article_type") {
  plos.response_fields <- c("id","journal","publication_date","article_type")
} else {
  plos.response_fields <- c("id","journal","publication_date","article_type",plos.search_field)
}
response <- searchplos(terms="*:*", fields=paste(plos.response_fields, collapse=','), toquery=plos.query, key = plos.api_key)
response.number <- response[[1]]
response.body <- response[[2]]

# Stop if no article was found
stopifnot (response.number > 0)

# Get response into the right format
dim(response.body) <- c(length(plos.response_fields),response.number)
response.body <- t(response.body)

# Rename first column
plos.response_fields[1] <- "doi"
colnames(response.body) <- plos.response_fields

# Strip time information from publication_date
response.body[,3] <- substr(response.body[,3],1,10)

if (plos.search_field == "author" ||
    plos.search_field == "affiliate") {
    response.body[,5] <- lapply(response.body[,5], function(x) paste(x, collapse=";"))
} else if (plos.search_field == "financial_disclosure") {
  # Remove whitespace
  response.body[,5] <- gsub("\n", " ", response.body[,5], fixed=TRUE)
  response.body[,5] <- gsub("^\\s+|\\s+$", "", response.body[,5])
}

# Save result as CSV file, using the query and today's date for the filename
# Results are saved in the "data-articles" subdirectory
plos.search_string <- gsub(" ", "_", tolower(plos.search_string))
plos.search_string <- gsub(".", "", plos.search_string, fixed=TRUE)
plos.data_articles <- "data-articles"
plos.csv <- paste(plos.data_articles, "/", plos.search_field, "_", plos.search_string, "_", today, ".csv", sep="")
write.csv(response.body, plos.csv, row.names=FALSE)

# Also write temporary CSV file that can be used by almFetch script
write.csv(response.body, "alm_in.csv", row.names=FALSE)