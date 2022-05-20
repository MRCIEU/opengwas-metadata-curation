library(plyr)
library(gsheet)
library(ggplot2)
library(data.table)
library(viridis)
library(hrbrthemes)
library(dplyr)
library(here)
# install.packages("hrbrthemes")

# Benjamin
url1<-"https://docs.google.com/spreadsheets/d/1d32FA5-Yw-1MQFMX5ONBPCMWryt49THnROL2AS8u5hw/edit#gid=970223356"
# Rebecca
url2<-"https://docs.google.com/spreadsheets/d/1JDv-ycajsd-32W2tigyd5hdNd9PXuasBbOHJdx0G7fs/edit?usp=sharing"

# Samuel
url3<-"https://docs.google.com/spreadsheets/d/1i0LevfdgQaRkmPnCLA8k1pzmyvI1Y4jd1bBFPh3FH0Y/edit#gid=970223356"

# Ryan
url4<-"https://docs.google.com/spreadsheets/d/1BH0xST8Iqe4hazhadLVmxduzGTxvKnSwXJcoaiRdeH4/edit#gid=970223356"

# Maria
url5<-"https://docs.google.com/spreadsheets/d/1zAldGEGRb3H0apLO529i7JqM7QnsZ_z4/edit#gid=972041573"

# Zak
url6<-"https://docs.google.com/spreadsheets/d/1fxgEGT34gHdRuUhazWNddUETMd5GLzgoJUbQ1M8C__o/edit#gid=970223356"

# Marina
url7<-"https://docs.google.com/spreadsheets/d/1VVWSo_4gvp3JmIy5ycC9RfXFc1zUPf-0Uk-isoyAi-k/edit#gid=970223356"

# Giulio
url8<-"https://docs.google.com/spreadsheets/d/1aYOWaNoO37eOzI3ZCXrEF1EmcgujW-Z9Jn7KnlmY_8A/edit?usp=drive_web&ouid=103571138679663288585"

url<-c(url1,url2,url3,url4,url5,url6,url7,url8)

a<-NULL
for(i in 1:length(url)){
	# i<-7
	url[i]
	a1<-data.frame(gsheet2tbl(url[i]))
    for(j in 1:ncol(a1))
    {
        ind <- which(a1[,j] == "-")
        a1[ind,j] <- NA
    }
	brm<-length(which(!is.na(a1$broad.mapping)))
	exm<-length(which(!is.na(a1$exact.mapping)))
	nam<-length(which(!is.na(a1$narrow.mapping)))
	inm<-length(which(!is.na(a1$incorrect)))
	idm<-length(which(!is.na(a1$inadequate)))
	exm2<-length(which(!is.na(a1$Exact))) #user identified exact match 
	nem<-length(which(!is.na(a1$non.EFO)))

	Names<-c("broad.mapping","exact.mapping","narrow.mapping","incorrect","inadequate","Exact","non.EFO","comments")

	Names<-Names[Names %in% names(a1)]

	Temp<-is.na(a1[,Names])
	N<-unlist(lapply(1:nrow(Temp), FUN=function(x) all(Temp[x,])))
	N.missing<-length(which(N))
	a[[i]]<-data.frame(matrix(c(exm,brm,nam,inm,idm,exm2,nem,N.missing),nrow=1,ncol=8))
}

a2<-do.call(rbind,a)
names(a2)<-c("exact.match","broad.match","narrow.match","incorrect","inadequate","exact","non-efo","N.missing")
a2$N<-100-a2$N.missing
a2$ID<-1:8
a2<-a2[a2$N!=0,names(a2) != "N.missing"]
# !names(a2) %in% c("N.missing","N")
a3<-a2
a3$exact.match<-a3$exact.match/a3$N*100
a3$broad.match<-a3$broad.match/a3$N*100
a3$narrow.match<-a3$narrow.match/a3$N*100
a3$incorrect<-a3$incorrect/a3$N*100
a3$inadequate<-a3$inadequate/a3$N*100
a3$exact<-a3$exact/a3$N*100
a3[,"non-efo"]<-a3[,"non-efo"]/a3$N*100

a2<-a2[,names(a2)!="N"]
long1 <- melt(setDT(a2), id.vars = "ID", variable.name = "match")
a3<-a3[,names(a3)!="N"]
long2 <- melt(setDT(a3), id.vars = "ID", variable.name = "match")

ggplot(long2, aes(fill=match, y=value, x=ID)) + 
    geom_bar(position="dodge", stat="identity")

ggplot(long2, aes(fill=match, y=value, x=ID)) + 
    geom_bar(position="stack", stat="identity")

long2<-long2[order(long2$ID),]
Plot2<-ggplot(long2, aes(fill=match, y=value, x=match)) + 
    geom_bar(position="dodge", stat="identity") +
    scale_fill_viridis(discrete = T, option = "E") +
    ggtitle("") +
    facet_wrap(~ID) +
    theme_ipsum() +
    theme(axis.text.x = element_text(angle = 90))+
    # theme(legend.position="none") +
    xlab("")

Plot1<-ggplot(long1, aes(fill=match, y=value, x=match)) + 
    geom_bar(position="dodge", stat="identity") +
    scale_fill_viridis(discrete = T, option = "E") +
    ggtitle("") +
    facet_wrap(~ID) +
    theme_ipsum() +
    theme(axis.text.x = element_text(angle = 90))+
    # theme(legend.position="none") +
    xlab("")

png(here("results/efo_mapping/mapping_percentage.png"),width=800,height=800)
Plot2
dev.off()

png(here("results/efo_mapping/mapping_absolute.png"),width=800,
	height=800)
Plot1
dev.off()

# How much agreement within pairs

a1 <- data.frame(gsheet2tbl(url[4]))
a2 <- data.frame(gsheet2tbl(url[5]))




get_dataset <- function(url) {
    a1 <- data.frame(gsheet2tbl(url))
    # remove hyphens to NA
    for(j in 1:ncol(a1)){
        ind <- which(a1[,j] == "-")
        a1[ind,j] <- NA
        a1[,j] <- trimws(a1[,j])
    }
    # remove incomplete rows
    rem <- apply(a1[,11:ncol(a1)], 1, function(i) sum(!is.na(i))) == 0
    a1 <- a1[!rem,]
    x <- bind_rows(
        a1 %>% select(OpenGWAS.Trait, efo=exact.mapping) %>%
            mutate(eval="Exact"),
        a1 %>% select(OpenGWAS.Trait, efo=broad.mapping) %>%
            mutate(eval="Broad"),
        a1 %>% select(OpenGWAS.Trait, efo=narrow.mapping) %>%
            mutate(eval="Narrow"),
        a1 %>% select(OpenGWAS.Trait, efo=inadequate) %>%
            mutate(eval="Inadequate")
    ) %>%
        subset(!is.na(efo)) %>%
        subset(!duplicated(OpenGWAS.Trait))
    a1 <- inner_join(a1, x, by="OpenGWAS.Trait")
    a1$Score1 <- as.numeric(a1$Score1)
    a1$Score2 <- as.numeric(a1$Score2)
    a1$Score3 <- as.numeric(a1$Score3)
    return(a1)
}

compare_paired_mappers <- function(url1, url2){
    a1 <- get_dataset(url1)
    a2 <- get_dataset(url2)
    a1 <- subset(a1, OpenGWAS.Trait %in% a2$OpenGWAS.Trait)
    a2 <- subset(a2, OpenGWAS.Trait %in% a1$OpenGWAS.Trait)
    ind <- match(a1$OpenGWAS.Trait, a2$OpenGWAS.Trait)
    a1 <- a1[ind,]
    stopifnot(all(a1$OpenGWAS.Trait == a2$OpenGWAS.Trait))

    # If mapper 1 says exact, does it agree with exact in mapper 2

    tibble(
        total_both_done = nrow(a1),
        exact_n1 = sum(!is.na(a1$exact.mapping)),
        exact_n2 = sum(!is.na(a2$exact.mapping)),
        exact_overlap = sum(!is.na(a1$exact.mapping) & !is.na(a2$exact.mapping)),
        exact_agreement = sum(a1$exact.mapping == a2$exact.mapping,na.rm=T) / sum(!is.na(a1$exact.mapping) | !is.na(a2$exact.mapping)),
        mapping_agreement = sum(a1$efo == a2$efo) / nrow(a1),
        eval_agreement = sum(a1$eval == a2$eval) / nrow(a1),
        frac_eval_agreement = sum(a1$eval[a1$efo==a2$efo] == a2$eval[a1$efo==a2$efo]) / sum(a1$efo==a2$efo)
    )
}

paircomp <- bind_rows(
    compare_paired_mappers(url4, url5) %>% mutate(pair="4+5"),
    compare_paired_mappers(url2, url3) %>% mutate(pair="2+3"),
    compare_paired_mappers(url6, url7) %>% mutate(pair="6+7") %>% str()
)

paircomp %>% summarise(
    mapping_agreement=sum(total_both_done * mapping_agreement) / sum(total_both_done),
    eval_agreement=sum(total_both_done * eval_agreement) / sum(total_both_done),
    frac_eval_agreement=sum(total_both_done * frac_eval_agreement) / sum(total_both_done)
)

# Agreement of score with mapping

compare_manual_automated <- function(url) {
    a1 <- get_dataset(url)
    a1 <- a1 %>%
    mutate(
        auto_choice=case_when(efo == Identifier1 ~ 1, efo == Identifier2 ~ 2, efo == Identifier3 ~ 3, TRUE ~ 4),
    )
    a1$auto_score[a1$auto_choice == 1] <- a1$Score1[a1$auto_choice == 1]
    a1$auto_score[a1$auto_choice == 2] <- a1$Score2[a1$auto_choice == 2]
    a1$auto_score[a1$auto_choice == 3] <- a1$Score3[a1$auto_choice == 3]
    a1 %>% mutate(url=url)
}

compare_manual_automated(url1)

res <- lapply(url[1:7], compare_manual_automated) %>% bind_rows()
str(res)
table(res$auto_choice)

summary(lm(I(auto_choice != 0) ~ Score1 + Score2, res))
summary(lm(I(auto_choice != 0) ~ Score1 + Score2 + Score3, res))

cor(res$Score1, res$Score2, use="pair")

table(res$Score1 > 0.9, res$auto_choice != 0)

group_by(res, Score1 > 0.9, auto_choice == 0) %>%
summarise(n=n())

library(pROC)
r <- pROC::roc(as.numeric(res$auto_choice != 0), as.numeric(res$Score1))
plot(r)
# Agreement

