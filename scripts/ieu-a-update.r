library(ieugwasr)
ieugwasr::select_api("dev1")
ieugwasr::get_access_token()
library(dplyr)
library(jsonlite)
library(httr)

ao <- gwasinfo() %>% filter(grepl("ieu-a-", id))

tab <- read.csv("../data/ieu-a-efo.csv", stringsAsFactors=FALSE) %>% 
	as_tibble() %>%
	filter(!is.na(keep))

table(ao$id %in% tab$igd_id)
table(tab$igd_id %in% ao$id)


add_ontology <- function(id, ont)
{
	a <- api_query(paste0("gwasinfo/", id)) %>% httr::content() %>% {.[[1]]}
	a$ontology <- ont
	a$group_name <- "public"
	b <- api_query(paste0("edit/edit"), query=a) %>% httr::content()
	bind_rows(as_tibble(a), as_tibble(b)) %>% apply(., 2, function(x) all(x[1]==x)) %>% all %>% print
}

ids <- unique(tab$igd_id)
for(id in ids)
{
	message(id)
	subset(tab, igd_id==id) %>% 
	{.$obo_id} %>% 
	gsub(":", "_", .) %>%
	paste(., collapse=";") %>%
	add_ontology(id=id, ont=.)
}




ao2 <- gwasinfo() %>% filter(grepl("ieu-a-", id))

ao2$ontology

ao3 <- gwasinfo(access_token=NULL) %>% filter(grepl("ieu-a-", id))
nrow(ao3)

