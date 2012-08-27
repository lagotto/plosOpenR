#' Fetch information about Twitter users
#'
#' @author Martin Fenner <mfenner@plos.org>

twitterFetch <- function(usernames, consumerKey=NULL, consumerSecret=NULL) {
  
  # Load required libraries
  library("twitteR")
  library('ROAuth')

  # Authenticate with Twitter
  if (!file.exists("Twittercred.RData")) {
    requestURL <- "https://api.twitter.com/oauth/request_token"
    accessURL = "http://api.twitter.com/oauth/access_token"
    authURL = "http://api.twitter.com/oauth/authorize"
    consumerKey = consumerKey
    consumerSecret = consumerSecret
    cred <- OAuthFactory$new(consumerKey=consumerKey,
                           consumerSecret=consumerSecret,
                           requestURL=requestURL,
                           accessURL=accessURL, 
                           authURL=authURL)
    cred$handshake()
    registerTwitterOAuth(cred)
    save(cred, file="Twittercred.RData")
  } else { 
    cred <- load("Twittercred.RData")
  }
  
  # Make sure usernames is a dataframe with a "username" column
  # You can also use a "event_user" column
  if(class(usernames) == "character") {
    usernames <- as.data.frame(usernames)
    colnames(usernames) <- c("username")
  } else if(class(usernames) == "list") {
    usernames <- as.data.frame(unlist(usernames))
    colnames(usernames) <- c("username")
  }
  stopifnot(is.data.frame(usernames))
  names(usernames)[names(usernames)=="event_user"] <- "username"
  stopifnot (!is.null(usernames$username))
  
  usernames$username <- paste ("@",usernames$username,sep="")
  usernames <- unique(usernames[,"username"])
  
  users <- data.frame()
  
  # Loop through usernames, catch 404 Not Found errors
  for (username in usernames) {
    response <- try(getUser(username), silent = TRUE)
    user <- if(class(response) != "try-error") response
    users <- rbind(users, as.data.frame(user))
  }
  users
}