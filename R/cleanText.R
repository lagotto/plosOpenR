#' Clean text
#'
#' @author Martin Fenner <mfenner@plos.org>

cleanText <- function(text) {

  text <- gsub("\n", " ", text, fixed=TRUE)
  text <- gsub("^\\s+|\\s+$", "", text)
  text <- gsub("                     ", " ", text, fixed=TRUE)
  text <- gsub("     ", " ", text, fixed=TRUE)
  text
}