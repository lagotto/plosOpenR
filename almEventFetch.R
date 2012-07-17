# Fetch Article Level Metrics events from PLoS
# Version 1.0, 07/09/12
# by Martin Fenner, mf@martinfenner.org
#
# In contrast to the almFetch script, this script collects metrics that have event-based information,
# i.e. a date/time, URL and author for every event. This information can be used for different visualizations,
# e.g. time series, or mapping. Currently the PLoS ALM API provides this information only for CiteULike and Twitter.

# Load required libraries
library(rplos)

# Load PLoS API key from .rProfile file
plos.api_key <- getOption("PlosApiKey")

# Load CSV file with PLoS DOIs
articles <- read.csv("alm_in.csv")

my.data <- data.frame()

# Loop through all provided DOIs
for (i in 1:nrow(articles))  {
  article <- articles[i,]
  # Calling the PLoS ALM API. Waiting 10 sec before calling the API again.
  response <- almplosallviews(article$doi, citations = TRUE, history = FALSE, downform='json', sleep=0, key = plos.api_key)
  
  # Parse journal name from DOI
  if (!is.null(article$journal)) {
    journal.name <- article$journal
  } else {
    plos.journals <- c(pbio="PLoS Biology", 
                       pmed="PLoS Medicine",
                       pone="PLoS ONE",
                       ppat="PLoS Pathogens",
                       pcbi="PLoS Computational Biology",
                       pntd="PLoS Neglected Tropical Diseases",
                       pgen="PLoS Genetics",
                       pctr="PLoS Clinical Trials")
    
    journal.key <- substr(article$doi,17,20)
    journal.name <- plos.journals[journal.key]
  } 
  
  # Parse information about article, clean up article title when importing
  article.pmid <- if (is.null(response$article$pub_med)) NA else response$article$pub_med
  article.title <- gsub("<italic>", "", response$article$title)
  article.title <- gsub("</italic>", "", article.title)
  article.published <- as.Date(response$article$published)
  article <- c(list(journal=journal.name), list(doi=article$doi), list(pmid=article.pmid), list(title=article.title), list(published=article.published))
  lst <- list()
  
  # Add events from sources that support them. Discard the other information. 
  for (source in response$article$source) {
    source.name <- tolower(source$source)
    if (source.name == "citeulike" && !is.null(source$citations)) {
      # TODO remove loop
      for (citation in source$citations) {
        lst["source"] <- source.name
        lst["event_id"] <- NA
        lst["event_type"] <- if (is.null(citation$citation["username"])) "group_bookmark" else "bookmark"
        lst["event_time"] <- citation$citation["post_time"]
        lst["event_user"] <- NA
        # TODO
        #lst["event_user"] <- if (is.null(citation$citation["username"])) "test" else "test2"
        
        lst["event_url"] <- citation$citation["uri"]
        lst["event_text"] <- NA
        
        event <- c(article, lst)
        my.data <- rbind(my.data, data.frame(event))
      }
    } else if (source.name == "twitter" && !is.null(source$citations)) {
      # TODO remove loop
      for (citation in source$citations) {
        lst["source"] <- source.name
        lst["event_id"] <-  citation$citation["id"]
        lst["event_type"] <- "tweet"
        # The PLoS API unfortunately returns two different time formats for Twitter, first one is RFC 2822
        event_time <- citation$citation["created_at"]
        if (substr(event_time,4,4) == ",") {
          lst["event_time"] <- strftime(strptime(event_time, "%a, %d %b %Y %H:%M:%S %z"))
        } else {
          lst["event_time"] <- strftime(strptime(event_time, "%a %b %d %H:%M:%S %z %Y"))
        }
        lst["event_user"] <- citation$citation["user"]
        lst["event_url"] <- citation$citation["uri"]
        lst["event_text"] <- citation$citation["text"]
        
        event <- c(article, lst)
        my.data <- rbind(my.data, data.frame(event))
      }
    } else {
      next
    }
  }
}

# Save result as CSV file
write.csv(my.data, "alm_ts_out.csv", row.names=FALSE)