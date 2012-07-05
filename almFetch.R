# Fetch Article Level Metrics from PLoS
# Version 1.0, 07/04/12
# by Martin Fenner, mf@martinfenner.org

suppressPackageStartupMessages(library(googleVis))

# Load required libraries
library(rplos)

plos.api_key <- c("K2HOqorgUIiuc7e")
plos.sources <- c("crossref", "mendeley", "facebook")
plos.dois <- c("10.1371/journal.pone.0018657", "10.1371/journal.pcbi.1000204", "10.1371/journal.pcbi.0010057", "10.1371/journal.pbio.1000242", "10.1371/journal.pmed.0020124")
plos.journals <- list(pone="PLoS ONE", 
                      pmed="PLoS Medicine",
                      pbio="PLoS Biology",
                      ppat="PLoS Pathogens")

my.data <- data.frame()

for (doi in plos.dois) {
  # Parse journal name from DOI
  journal.key = substr(doi,17,20)
  
  for (source in plos.sources) {
    response <- almplosallviews(doi, source, citations = FALSE, history = FALSE, 'json', key = plos.api_key)
    
    data.tmp <- data.frame(response$article)
    my.data <- rbind(my.data, data.tmp)
  }
}