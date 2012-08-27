#' Clean text
#'
#' @author Martin Fenner <mfenner@plos.org>

cleanText <- function(text) {

  # Load required libraries
  library(stringr)
  
  text <- str_trim(text)
  text <- gsub("                     ", " ", text, fixed=TRUE)
  text <- gsub("     ", " ", text, fixed=TRUE)
  text <- gsub("</?(italic|sub|sup)>", "", text)
  text <- gsub("(“|”|\")", "'", text)

  text
}