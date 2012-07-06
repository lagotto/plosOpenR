# Fetch all PLoS articles for a given author
# Version 1.0, 07/05/12
# by Martin Fenner, mf@martinfenner.org

suppressPackageStartupMessages(library(googleVis))

# Load required libraries
library(rplos)

# Load required information
plos.api_key <- c("K2HOqorgUIiuc7e")

# Name of author to search for
plos.author <- c("Petra Dersch")

# Calling the PLoS ALM API
response <- plosauthor(plos.author, fields = 'id,title', limit = 50, results = TRUE, key = plos.api_key)
plos.dois <- as.data.frame(response[2])

# Change column "id" to "doi"
colnames(plos.dois) <- c("doi", "title")

# Save result as CSV file
write.csv(plos.dois, "alm_in.csv", row.names=FALSE)