# Fetch Article Level Metrics from PLoS
# Version 1.1, 07/05/12
# by Martin Fenner, mf@martinfenner.org

suppressPackageStartupMessages(library(googleVis))

# Load required libraries
library(rplos)

# Load required information
plos.api_key <- c("K2HOqorgUIiuc7e")
plos.sources <- c("CiteULike",
                  "Connotea", 
                  "CrossRef",
                  "Nature",
                  "Postgenomic", 
                  "PubMed Central",
                  "Scopus",
                  "Counter",
                  "Research Blogging",
                  "Biod",
                  "PubMed Central Usage Stats",
                  "Facebook",
                  "Mendeley",
                  "Twitter")
plos.journals <- list(pbio="PLoS Biology", 
                      pmed="PLoS Medicine",
                      pone="PLoS ONE",
                      ppat="PLoS Pathogens",
                      pcbi="PLoS Computational Biology",
                      pntd="PLoS Neglected Tropical Diseases",
                      pgen="PLoS Genetics")

# Load CSV file with PLoS DOIs
input <- read.csv("alm_in.csv")

plos.dois <- input$doi
my.data <- data.frame()

# Loop through all provided DOIs
for (doi in plos.dois) {
  # Calling the PLoS ALM API
  response <- almplosallviews(doi, citations = TRUE, history = FALSE, downform='json', sleep=5, key = plos.api_key)

  # Parse journal name from DOI
  journal.key <- substr(doi,17,20)
  journal.name <- plos.journals[[journal.key]]
      
  # Parse information about article
  if (is.null(response$article$pub_med)) article.pmid <- NA else article.pmid <- response$article$pub_med
  article.title <- response$article$title
  article.published <- as.Date(response$article$published)
  article.age_in_days <- Sys.Date() - article.published
  article <- c(list(journal=journal.name), list(doi=doi), list(pmid=article.pmid), list(title=article.title), list(published=article.published), list(age_in_days=article.age_in_days))

  # Add citation_counts from sources. We will not use all sources.
  lst <- list()
  
  for (source in response$article$source) {
    if (source$source == "CiteULike" || 
        source$source == "CrossRef" ||
        source$source == "PubMed Central" ||
        source$source == "Scopus" ||
        source$source == "Twitter") {
      lst[source$source] <- source$count
    } else if (source$source == "Counter") {
      lst[source$source] <- source$count
    } else if (source$source == "PubMed Central Usage Stats") {
      lst[source$source] <- source$count
    } else if (source$source == "Facebook") {
      lst[source$source] <- source$count
    } else if (source$source == "Mendeley") {
      lst[source$source] <- source$count
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