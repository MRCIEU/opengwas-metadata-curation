library(ieugwasr)
library(urltools)
library(jsonlite)
library(dplyr)


get_ontologies <- function(trait, api='http://www.ebi.ac.uk/ols/api/search', nrow=10, ont="&ontology=efo")
{
	url <- paste0('http://www.ebi.ac.uk/ols/api/search?q=', urltools::url_encode(trait), "&rows=", nrow, ont)
	o <- read_json(url)$response$docs
	x <- lapply(o, dplyr::as_tibble) %>% dplyr::bind_rows()
	if("description" %in% names(x))
	{
		x$description <- sapply(x$description, function(x) paste(x, collapse="; "))		
	} else {
		x$description <- ""
	}
	x
}


ao <- gwasinfo()
a <- subset(ao, grepl("ieu-a", id))
l <- list()
for(i in 1:nrow(a))
{
	message(i, " of ", nrow(a))
	o <- get_ontologies(a$trait[i]) 
	if(nrow(o) == 0)
	{
		l[[i]] <- dplyr::tibble(igd_id=a$id[i], igd_trait=a$trait[i])
		next
	}
	o <- o %>% dplyr::select(obo_id, label, description)
	o$igd_id <- a$id[i]
	o$igd_trait <- a$trait[i]
	o <- dplyr::select(o, igd_id, igd_trait, dplyr::everything())
	l[[i]] <- o
}

m <- bind_rows(l)

write.csv(m, file="data/ieu-a-efo-candidates.csv")
