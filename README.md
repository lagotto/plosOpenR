# R wrappers for the PLoS Search and ALM API

The Open Access publisher Public Library of Science (PLoS) is providing [two APIs](http://api.plos.org/) for their Search and Article Level Metrics (ALM) API. [rplos](https://github.com/ropensci/rplos) is a set of R scripts by [rOpenSci](https://github.com/ropensci) to facilitate talking to these APIs. The plosOpenR scripts enhance rplos by providing some higher level functions, including visualizations of the results.

Analyzing the article level metrics for a set of PLoS articles involves three steps:

* Retrieve a set of articles through the Search API
* Collect the metrics for these articles
* Visualize the metrics 

One incentive for these R wrappers is to further improve rplos by the addition of PLoS funding information. Throughout, this will be showed exemplary by EC funded research visible in the PLoS domain. The FP7 funded project [OpenAIRE](http://www.openaire.eu/) has the objective to set up a Open Access Infrastructure for Research in Europe. OpenAIRE exposes EC funding information stored in [CORDIS](http://cordis.europa.eu/home_de.html) via its [OAI-PMH Interface](http://api.openaire.research-infrastructures.eu:8280/is/mvc/openaireOAI/oai.do?verb=Identify). These data  can be reused to identify EC funded contributions in the PLoS domain. 
  
## Retrieve a set of articles through the PLoS Search API
The **articlesSearch** script can query the PLoS Search API through a variety of criteria, including:

* Title
* Author
* Editor
* Affiliation
* Funder (through the financial disclosure field)

The results can be filtered by date, article type and main subject category.

Additionally, the function **plosSearchFinancial** provides an alternative  interface to query the PLoS Search API  by a Funder.

The so retrieved funding information can be matched against data provided by the funder. In the case of EC FP7 publications, **projectsFetch.R** queries OpenAIRE OAI-PMH interface for EC funded Projects. It returns:

* Grant ID
* Project Acronym
* SC 39 closure

**grantFetch.R** merges EC and PLoS data tables  by the Grant ID.
 
## Collect the metrics for these articles
The **almSearch** script takes the output of the **articlesSearch** script as input, but can use any list of PLoS DOIs. The script generates a table of article level metrics for these DOIs and stores them in a CSV file.

Retrieving the metrics for a large set of articles (> 250) can take a long time, and more than 1000 DOIs should probably not retrieved at a time. 

The **almEventSearch** script collects individual events (bookmarks, tweets, etc.) - great for a time series analysis. Only CiteULike and Twitter are currently supported through the API.

The **counterFetch.R** script collects monthly usage events for a single PLoS article.

## Visualize the metrics
Article level metrics are much easier to understand through visualizations. The following visualizations are available:

* Word cloud
* Bubble chart
* Heat map
* Density plot
* Time Series Usage events

The scripts that generate these visualizations take the output of the **almFetch** script. Time Series Usage events is invoked by **counterFetch.R** script. 

## Examples
Example visualizations are available in the **examples** folder.
