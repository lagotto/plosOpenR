#'helper function to retrieve Geocoding information from Google Geocoding API 
#'<https://developers.google.com/maps/documentation/geocoding/>
#'Supplements ggmap's geocode function
#'@import RCurl RJSONIO
#'@param address a character string specifying a location of interest 
#'(e.g. "Bielefeld University")
#'@value returns data.frame with long_name, short_name and indication of the address type
#'(eg point_of_interest,politically, locality, country ...)
#'@author Najko Jahn <najko.jahn@uni-bielefeld.de>

geoCodeType <- function (address = NA) {
  
  my.address <- data.frame()
  
  .args <- list()
  .args$address <- gsub(" ","+", address)
  .args$sensor <- "false"
  
  #query
  doc <- fromJSON(getForm("http://maps.googleapis.com/maps/api/geocode/json",  
                          .params = .args))
  
  if(doc$status != 'OK'){
    warning(paste('geocode failed with status ', doc$status, ', address = "', 
                  address, '"', sep = ''), call. = FALSE)
    return(data.frame(long_name = NA, short_name = NA, type = NA))  
    
  } else {
  
  #recursive parsing omitting last occurence since type is undefined
  for (i in 1 : (max(length(doc$results[[1]]$address_components)) - 1)) {
    
    tt <- do.call("cbind", doc$results[[1]]$address_components[[i]])
    my.address <- rbind(my.address,tt,deparse.level = 0)
  }
  }  
  return(my.address) 
}
