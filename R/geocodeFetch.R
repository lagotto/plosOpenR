#' Map location information
#' 
#' @author Martin Fenner <mfenner@plos.org>

geocodeFetch <- function(data, x="affiliate", url="http://where.yahooapis.com/geocode", appid) {
  
  # Load required libraries
  #library(dismo)
  library(RJSONIO)
  library(RCurl)
  library (plyr)

  getLocation <- function(data) {
    if (data[[x]] != "none") {
      query <- unlist(strsplit(data[[x]], ", ?"))
      number <- if (grepl("(United States|Canada)", tail(query, 1))) 3 else 2
      query <- tail(query, number)
      query <- paste(query, collapse=", ")
      response <- getForm(url, .params= c(q=query, flags="JCG", appid=appid))
      response <- fromJSON(response)
      if (response$ResultSet$Error > 0) {
        response <- data.frame(latitude=c(NA), longitude=c(NA))
      } else {
        response <- rbind(response$ResultSet$Results[[1]])
        response <- subset(response, select=c("latitude","longitude"))
      }
    } else {
      response <- data.frame(latitude=c(NA), longitude=c(NA))
    }
    response <- cbind(data, response)
  }
  data <- ddply(data, 1, getLocation)
}