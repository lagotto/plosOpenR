# Detecting EC funded resources in the PLoS Domain

## EC Funding Information

'projectsFetch.R' queries OpenAIRE OAI-PMH interface for EC funded Projects. It returns ' id', 'acronym' , 'sc39'. Output is written to './data/projects.csv'.

## PLoS 

'plosFetch.R' queries PLoS Search API for EC funded publications. It searches in the ifeld 'financial_disclosure' and returns 'financial_disclosure' , 'doi' , 'publication_date'. Output is written to './data/plos.csv'.

## Merge EC Funding Information and PLoS by Grant ID

'grantFetch.R' loads plos and project tables. Afterwards it greps for GrantID every row of the column 'financial_disclosure'. It returns a merged data.set with the detected publications.Output is writen to './data/plosGrant.csv'

**NB: Work in Progress**



