#' Fetch Article Level Metrics from PLOS
#' @import rplos stringr
#' @param articles list of DOIS (dataframe)
#' Provide a dataframe with at least one DOI column. The function calls the 
#' PLOS ALM API and adds the response to the input dataframe
#' 
#' @author Martin Fenner, mfenner@plos.org

almFetch <- function(articles, key=getOption("PlosApiKey")) {
  
stopifnot (is.data.frame(articles))
stopifnot (!is.null(articles$doi))

# Load required libraries
library(rplos)
library(stringr)

alm <- data.frame()

# Loop through all provided DOIs
for (i in 1:nrow(articles))  {
  article <- articles[i,]
  # Calling the PLoS ALM API. Waiting 10 sec before calling the API again.
  response <- almplosallviews(article$doi, citations = TRUE, history = FALSE, downform='json', sleep=2, key = plos.api_key)

  # Add PMID if it exists
  article.pmid <- if (is.null(response$article$pub_med)) NA else response$article$pub_med
  article <- c(article, list(pmid=article.pmid))

  # Parse journal name from DOI unless we know the name already
  if (is.null(article$journal)) {
    plos.journals <- list(pbio="PLoS Biology", 
                          pmed="PLoS Medicine",
                          pone="PLoS ONE",
                          ppat="PLoS Pathogens",
                          pcbi="PLoS Computational Biology",
                          pntd="PLoS Neglected Tropical Diseases",
                          pgen="PLoS Genetics",
                          pctr="PLoS Clinical Trials")
    
    journal.key <- substr(article$doi,17,20)
    article.journal <- plos.journals[[journal.key]]
    article <- c(article, list(journal=article.journal))
  } 
  
  # Parse publication date unless we know it already
  if (is.null(article$publication_date)) {
    article.publication_date <- as.Date(response$article$published)
    article <- c(article, list(publication_date=article.publication_date))
  }
  
  # Parse title from response unless we know it already
  if (is.null(article$title)) {
    article.title <- gsub("<italic>", "", response$article$title)
    article.title <- gsub("</italic>", "", article.title)
    article.title <- iconv(article.title, from = "latin1", to = "UTF-8")
    article.title <- gsub("\n", " ", article.title, fixed=TRUE)
    article.title <- gsub("                    ", "", article.title, fixed=TRUE)
    article.title <- str_trim(article.title)
    article <- c(article, list(title=article.title))
  }
  
  lst <- list()
  
  # Add citation_counts from sources. We will not use all sources, and need special parsing for some sources.
  for (source in response$article$source) {
    source.name <- tolower(source$source)
    if (source.name == "citeulike" || 
        source.name == "crossref" ||
        source.name == "scopus" ||
        source.name == "twitter") {
      lst[source.name] <- source$count
    } else if (source$source == "PubMed Central") {
      lst["pubmed"] <- source$count
    } else if (source.name == "counter") {
      views <- source$citations[[1]]$citation$views
      pdf_views <- sum(as.numeric(sapply(views, `[[`, "pdf_views")))
      html_views <- sum(as.numeric(sapply(views, `[[`, "html_views")))
      xml_views <- sum(as.numeric(sapply(views, `[[`, "xml_views")))
      lst["counter_pdf"] <- pdf_views
      lst["counter_html"] <- html_views
      lst["counter_xml"] <- xml_views
    } else if (source$source== "PubMed Central Usage Stats") {
      views <- source$citations[[1]]$citation$views
      pdf <- sum(as.numeric(sapply(views, `[[`, "pdf")))
      html <- sum(as.numeric(sapply(views, `[[`, "full-text")))
      lst["pmc_pdf"] <- pdf
      lst["pmc_html"] <- html
    } else if (source.name == "facebook") {
      doi_count <- if(is.null(source$citations[[1]]$citation$total_count)) 0 else source$citations[[1]]$citation$total_count
      fulltext_count <- if(is.null(source$citations[[2]]$citation$total_count)) 0 else source$citations[[2]]$citation$total_count
      lst[source.name] <- doi_count + fulltext_count
    } else if (source.name == "mendeley") {
      citation <- source$citations[[1]]$citation
      readers <- if(is.null(citation$stats)) 0 else citation$stats$readers
      groups <- if(is.null(citation$groups)) 0 else length(citation$groups)
      lst["mendeley_readers"] <- readers
      lst["mendeley_groups"] <- groups
    } else {
      next
    }
  }
  article <- c(article, lst)
  response <- rbind(alm, data.frame(article))
}
response
}