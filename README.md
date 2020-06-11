# Adding ontology mappings to OpenGWAS

There have been a few attempts to map ontologies to each dataset in OpenGWAS. Try to collect them here, though some might have been lost when UoB migrated from Google to Microsoft.


## Useful links

- Ontology lookup service (OLS): https://www.ebi.ac.uk/ols/index
- API for OLS: https://www.ebi.ac.uk/ols/docs/api
- UK Biobank dictionary: https://biobank.ctsu.ox.ac.uk/crystal/index.cgi
- Zooma automated ontology mapping tool: https://www.ebi.ac.uk/spot/zooma/

To obtain the meta data for an ontological term:

```
curl -L 'http://www.ebi.ac.uk/ols/api/terms?id=MONDO_0002009' -i -H 'Accept: application/json'
```


## Mapping `ieu-a` to EFO terms










## Common EFO terms

```
EFO:0009374 energy intake measurement
EFO:0005241 employment status
EFO:0009520 contraception
EFO:0004784 self reported educational attainment
EFO:0003931 bone fracture
EFO:0004731 eye measurement
```


## Getting SD for ukb-b

```
ibrary(parallel)
library(data.table)
library(dplyr)
setwd("/mnt/storage/private/mrcieu/research/mr-eve/UKBB_replication/replication/results")
d <- list.dirs()[-1]
o <- mclapply(d, function(x)
{
    a <- fread(file.path(x, "phen.txt"), header=TRUE)

    tibble(id=x, sd=c(a$discovery, a$replication) %>% sd(., na.rm=TRUE))
}) %>% bind_rows()
save(o, file="ukb-b_units.rdata")
```
