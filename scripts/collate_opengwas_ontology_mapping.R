library(plyr)
library(gsheet)
library(ggplot2)
library(data.table)
library(viridis)
library(hrbrthemes)
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

png("~/OpenGWAS/ontology_mapping_project/results/mapping_percentage.png",width=800,height=800)
Plot2
dev.off()

png("~/OpenGWAS/ontology_mapping_project/results/mapping_absolute.png",width=800,
	height=800)
Plot1
dev.off()
