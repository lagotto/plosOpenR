# Fetch all PLoS articles for a given funder
# Version 1.0, 07/06/12
# by Martin Fenner, mf@martinfenner.org

# Load required libraries
library(rplos)

# Load required information
plos.api_key <- c("K2HOqorgUIiuc7e")

# Name of funder to search for
plos.funder <- c("Medecins Sans Frontieres")

# Calling the PLoS ALM API
response <- searchplos(plos.funder, fields=c('id'), toquery=paste("financial_disclosure:", plos.funder, sep =""), limit=1000, key=plos.api_key)
plos.dois <- as.data.frame(response[2])

# Change column "id" to "doi"
colnames(plos.dois) <- c("doi")

# Save result as CSV file
write.csv(plos.dois, "alm_in.csv", row.names=FALSE)