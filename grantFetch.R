plos <- read.csv("./data/plos.csv",header=T, sep=",")

projects <- read.csv("./data/projects.csv",header=T, sep=",") 


plos.grant <- data.frame()
for (i in unlist(projects$id)) {

tmp <- grep(i, plos$financial_disclosure)

id.tmp <- rep(i, times = length(tmp))
plos.tmp <- cbind(plos[tmp,],id.tmp)

plos.grant <- rbind(plos.grant,plos.tmp)

}
