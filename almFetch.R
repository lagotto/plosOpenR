# Fetch Article Level Metrics from PLoS
# Version 1.3, 07/08/12
# by Martin Fenner, mf@martinfenner.org

# Load required libraries
library(rplos)

# Load PLoS API key from .rProfile file
plos.api_key <- getOption("PlosApiKey")

# Load required information
plos.journals <- list(pbio="PLoS Biology", 
                      pmed="PLoS Medicine",
                      pone="PLoS ONE",
                      ppat="PLoS Pathogens",
                      pcbi="PLoS Computational Biology",
                      pntd="PLoS Neglected Tropical Diseases",
                      pgen="PLoS Genetics",
                      pctr="PLoS Clinical Trials")

# Load CSV file with PLoS DOIs
input <- read.csv("alm_in.csv")

plos.dois <- input$doi
my.data <- data.frame()

# Loop through all provided DOIs
for (doi in plos.dois) {
  # Calling the PLoS ALM API. Waiting 10 sec before calling the API again.
  response <- almplosallviews(doi, citations = TRUE, history = FALSE, downform='json', sleep=0, key = plos.api_key)

  # Parse journal name from DOI
  if (is.null(input.journal)) {
    journal.key <- substr(doi,17,20)
    journal.name <- plos.journals[[journal.key]]
  }
      
  # Parse information about article, clean up article title when importing
  article.pmid <- if (is.null(response$article$pub_med)) NA else response$article$pub_med
  article.title <- gsub("<italic>", "", response$article$title)
  article.title <- gsub("</italic>", "", article.title)
  #article.title <- gsub("\n", "", article.title, fixed=TRUE)
  article.published <- as.Date(response$article$published)
  article.age_in_days <- Sys.Date() - article.published
  article <- c(list(journal=journal.name), list(doi=doi), list(pmid=article.pmid), list(title=article.title), list(published=article.published), list(age_in_days=article.age_in_days))
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
      lst[source.name] <- pdf_views + html_views + xml_views
    } else if (source$source== "PubMed Central Usage Stats") {
      views <- source$citations[[1]]$citation$views
      pdf <- sum(as.numeric(sapply(views, `[[`, "pdf")))
      html <- sum(as.numeric(sapply(views, `[[`, "full-text")))
      lst["pmc"] <- pdf + html
    } else if (source.name == "facebook") {
      doi_count <- source$citations[[1]]$citation$total_count
      fulltext_count <- source$citations[[2]]$citation$total_count
      citation <- unlist(source$citations, recursive=FALSE)
      lst[source.name] <- doi_count + fulltext_count
    } else if (source.name == "mendeley") {
      citation <- source$citations[[1]]$citation
      readers <- if(is.null(citation$stats)) 0 else citation$stats$readers
      groups <- if(is.null(citation$groups)) 0 else length(citation$groups)
      lst[source.name] <- readers + groups
    } else {
      next
    }
  }
  article <- c(article, lst)

  data.tmp <- data.frame(article)
  my.data <- rbind(my.data, data.tmp)
}

# Save result as CSV file
write.csv(my.data, "alm_out.csv", row.names=FALSE)