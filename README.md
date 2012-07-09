# R wrappers for the PLoS Search and ALM API

The Open Access publisher Public Library of Science (PLoS) is providing [two APIs](http://api.plos.org/) for their Search and Article Level Metrics (ALM) API. [rplos](https://github.com/ropensci/rplos) is a set of R scripts by [rOpenSci](https://github.com/ropensci) to facilitate talking to these APIs. The plosOpenR scripts enhance rplos by providing some higher level functions, including visualizations of the results.

Analyzing the article level metrics for a set of PLoS articles involves three steps:

* Retrieve a set of articles through the Search API
* Collect the metrics for these articles
* Visualize the metrics 

## Retrieve a set of articles through the PLoS Search API
The **articlesSearch** script can query the PLoS Search API through a variety of criteria, including:

* Title
* Author
* Editor
* Affiliation
* Funder (through the financial disclosure field)

The results can be filtered by date, article type and main subject category.

## Collect the metrics for these articles
The **almSearch** script takes the output of the **articlesSearch** script as input, but can use any list of PLoS DOIs. The script generates a table of article level metrics for these DOIs and stores them in a CSV file.

Retrieving the metrics for a large set of articles (> 250) can take a long time, and more than 1000 DOIs should probably not retrieved at a time. 

The **almEventSearch** script collects individual events (bookmarks, tweets, etc.) - great for a time series analysis. Only CiteULike and Twitter are currently supported through the API.

## Visualize the metrics
Article level metrics are much easier to understand through visualizations. The following visualizations are available:

* Word cloud
* Bubble chart
* Heat map
* Density plot

The scripts that generate these visualizations take the output of the **almFetch** script. 

## Examples
Example visualizations are available in the **examples** folder.
