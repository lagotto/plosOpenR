require(XML)

url.plos <- c("http://api.plos.org/search?q=financial_disclosure:%22FP7%22&fl=id,financial_disclosure,publication_date,counter_total_all")

api.key <- c("BJ0AW4rFUPfHtXi")

my.data <- data.frame()

for ( i in seq(0,800 , by = 10)){

doc <- xmlTreeParse(paste(url.plos, "&start=", i, "&=rows=10", "api_key=", api.key, sep=""), useInternal=T)

financial_disclosure <- xpathSApply(doc, "//result//doc//str[@name='financial_disclosure']",xmlValue)

doi <- xpathSApply(doc, "//result//doc//str[@name='id']",xmlValue)

publication_date <- xpathSApply(doc, "//result//doc//date[@name='publication_date']",xmlValue)

if(length(financial_disclosure) == 0)
 break

data.tmp <- data.frame(financial_disclosure, doi, publication_date)

my.data <- rbind(my.data, data.tmp)

}


