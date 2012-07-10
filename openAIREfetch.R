#get ec projects

require(XML)

url.ini <- "http://api.openaire.research-infrastructures.eu:8280/is/mvc/openaireOAI/oai.do?verb=ListRecords&set=projects&metadataPrefix=oaf"

doc = xmlTreeParse(url.ini, useInternal=T)

id <- xpathSApply(doc,"//r:grant_agreement_number", namespaces= (c(r="http://www.openaire.eu/oaf")) ,xmlValue)

acronym <- xpathSApply(doc,"//r:acronym", namespaces= (c(r="http://www.openaire.eu/oaf")),xmlValue)

sc39 <- xpathSApply(doc,"//r:sc39", namespaces= (c(r="http://www.openaire.eu/oaf")),xmlValue)

my.data.fp7 <- data.frame(id,acronym,sc39)

url <- ("http://api.openaire.research-infrastructures.eu:8280/is/mvc/openaireOAI/oai.do?verb=ListRecords&resumptionToken=")

for (i in seq(50, 15000, by = 50)) {

  url.d <- paste(url, "projects___", i, sep="")

  doc <- xmlTreeParse(url.d,useInternal=T)
  
  id <- xpathSApply(doc,"//r:grant_agreement_number", namespaces= (c(r="http://www.openaire.eu/oaf")) ,xmlValue)

  acronym <- xpathSApply(doc,"//r:acronym", namespaces= (c(r="http://www.openaire.eu/oaf")),xmlValue)

  sc39 <- xpathSApply(doc,"//r:sc39", namespaces= (c(r="http://www.openaire.eu/oaf")),xmlValue)

  my.data.fp7.tmp <- data.frame(id,acronym,sc39)
  
  my.data.fp7 <- rbind(my.data.fp7,my.data.fp7.tmp)
}
