#counter stats distribution for single PLoS article (DOI)

require(rplos)
require(chron)
require(ggplot2)

#load basic

doi <- c("10.1371/journal.pmed.0020124")

plos.api_key ="APIKEY"

my.date <- as.Date(Sys.time(), format="%Y-%m-%d"))

#fetch

tt <- almplosallviews(doi, source_ = "counter", 'json', 
                        citations= T, history =T, key = plos.api_key)  

my.data <- data.frame(do.call("rbind",
                              tt$article$source[[1]]$citations[[1]]$citation$views))

published <- as.Date(unlist(tt$article$published), format ="%Y-%m-%d")

seq.date <- seq.dates(julian(published),julian(my.date),by= "month")

my.data.tmp <- data.frame(my.data[1: length(seq.date),
                                  c("pdf_views","xml_views","html_views")],seq.date)

#values to numeric
my.data.tmp$html_views <- as.numeric(levels(my.data.tmp$html_views))[my.data.tmp$html_views]
my.data.tmp$pdf_views <- as.numeric(levels(my.data.tmp$pdf_views))[my.data.tmp$pdf_views]
my.data.tmp$xml_views <- as.numeric(levels(my.data.tmp$xml_views))[my.data.tmp$xml_views]

#sample plot (time stamp events log scale )

ggplot(my.data.tmp, aes(as.Date(seq.date), html_views)) +
  stat_smooth() + geom_point() + coord_trans(y="log10")

