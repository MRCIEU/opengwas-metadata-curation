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

write.csv(m, file="ieu-a-efo-candidates.csv")



ukb <- subset(ao, grepl("ukb-", id))

ukb$type <- ""
ukb$trait_sanitised <- ukb$trait
ukb$icd10 <- NA
index <- grepl("ICD10", ukb$trait)
temp <- do.call(rbind, strsplit(ukb$trait[index], split="ICD10: "))[,2] %>% 
{do.call(rbind, strsplit(sub(" ", ";;;", .), ";;;"))}
ukb$icd10[index] <- temp[,1]
ukb$trait_sanitised[index] <- temp[,2]
ukb$type[index] <- "disease"

ukb$trait_sanitised <- gsub("Treatment speciality of consultant \\(recoded\\): ", "", ukb$trait_sanitised)

index <- grepl("Treatment/medication", ukb$trait_sanitised)
ukb$type[index] <- "treatment"
ukb$trait_sanitised <- gsub("Treatment/medication code: ", "", ukb$trait_sanitised)


index <- grepl("OPCS", ukb$trait)
temp <- do.call(rbind, strsplit(ukb$trait[index], split="OPCS: "))[,2] %>% 
{do.call(rbind, strsplit(sub(" ", ";;;", .), ";;;"))}
ukb$opcs[index] <- temp[,1]
ukb$trait_sanitised[index] <- temp[,2]
ukb$type[index] <- "disease"


index <- grepl("Operation code: ", ukb$trait_sanitised)
ukb$trait_sanitised <- gsub("Operation code: ", "", ukb$trait_sanitised)
ukb$type[index] <- "treatment"

table(ukb$type)
write.table(subset(ukb, select=c(trait_sanitised, type)), "ukb.txt", row=F, col=F, qu=F, sep="\t")




l <- list()
for(i in 1:nrow(ukb))
{
	message(i, " of ", nrow(ukb))
	o <- get_ontologies(ukb$trait_sanitised[i]) 
	if(nrow(o) == 0)
	{
		l[[i]] <- dplyr::tibble(igd_id=ukb$id[i], igd_trait=ukb$trait[i])
		next
	}
	o <- o %>% dplyr::select(obo_id, label, description)
	o$igd_id <- ukb$id[i]
	o$igd_trait <- ukb$trait[i]
	o <- dplyr::select(o, igd_id, igd_trait, dplyr::everything())
	l[[i]] <- o
}
m2 <- bind_rows(l)
write.csv(m2, file="ukb-efo.csv")



ubm <- subset(ao, grepl("ubm-a", id))
l <- list()
for(i in 1:10)
{
	message(i, " of ", nrow(ubm))
	o <- get_ontologies(ubm$trait[i])
	if(nrow(o) == 0)
	{
		l[[i]] <- dplyr::tibble(igd_id=ubm$id[i], igd_trait=ubm$trait[i])
		next
	}
	o <- o %>% dplyr::select(obo_id, label, description)
	o$igd_id <- ubm$id[i]
	o$igd_trait <- ubm$trait[i]
	o <- dplyr::select(o, igd_id, igd_trait, dplyr::everything())
	l[[i]] <- o
}
