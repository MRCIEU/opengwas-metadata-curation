
b<-data.table::fread("~/OpenGWAS/ontology_mapping_project/data/Copy of opengwas-traits-jan25-mapped - traits-mapped-feb8-nochebi.csv-converted.tsv")
names(b)[names(b) == "Score"]<-c("Score1","Score2","Score3")
names(b)[names(b) == "Identifier"]<-c("Identifier1","Identifier2","Identifier3")
b<-b[,c("OpenGWAS Trait", "Tool Mapping #1", "Identifier1","Score1","Tool Mapping #2","Identifier2","Score2","Tool Mapping #3","Identifier3","Score3")]
b<-data.frame(b)
b<-b[!duplicated(b$OpenGWAS.Trait),]
head(b)
b1<-b$OpenGWAS.Trait

ao<-ieugwasr::gwasinfo()
ubm<-ao$trait[ao$batch == "ubm"]
id<-unlist(strsplit(ao$id,split="-"))
ao$batch<-id[seq(1,length(id),3)]
ao<-ao[!ao$batch %in% c("eqtl","ubm"),]
ao<-ao[ao$trait!="NA",]
ao<-ao[!is.na(ao$trait),]
ao<-ao[!duplicated(ao$trait),]
ao<-ao[ao$trait %in% b1,]
pos1<-round(runif(360, min=1, max=nrow(ao)),0)
pos1<-unique(pos1)
Pos<-1:nrow(ao)
Pos<-Pos[!Pos %in% pos1]
pos2<-round(runif(360-length(pos1), min=1, max=max(Pos)),0)
pos1<-c(pos1,pos2)
if(any(duplicated(pos1))) stop("duplicates")
ao1<-ao[pos1,]
trait<-ao1$trait
if(any(duplicated(trait))) stop("duplicates")
trait1<-trait[1:90]
trait2<-trait[91:180]
trait3<-trait[181:270]
trait4<-trait[271:360]
ao2<-ao[!ao$trait %in% trait,]
pos2<-round(runif(10, min=1, max=nrow(ao2)),0)
pos2<-unique(pos2)
if(any(duplicated(pos2))) stop("duplicates")
trait5<-ao2$trait[pos2]
if(any(trait5 %in% trait)) stop("duplicates")

#ids1 rlang & msob
#ids2 zthorn & mvabi
#ids3 sneave & rcarn
#ids4 bwoo & gcento 
# 

any(duplicated(c(trait1,trait2,trait3,trait4,trait5)))
a1<-data.frame(matrix(c(trait1,rep("Ryan Langdon",length(trait1)),rep("Maria Sobczyk-Barad",length(trait1))),byrow=FALSE,nrow=length(trait1),ncol=3))
names(a1)<-c("trait","mapper1","mapper2")

a2<-data.frame(matrix(c(trait2,rep("Zak Thornton",length(trait2)),rep("Marina Vabistsevits",length(trait2))),byrow=FALSE,nrow=length(trait2),ncol=3))
names(a2)<-c("trait","mapper1","mapper2")

a3<-data.frame(matrix(c(trait3,rep("Samuel Neaves",length(trait3)),rep("Rebecca Carnegie",length(trait3))),byrow=FALSE,nrow=length(trait3),ncol=3))
names(a3)<-c("trait","mapper1","mapper2")


a4<-data.frame(matrix(c(trait4,rep("Benjamin Woolf",length(trait4)),rep("Giulio Centorame",length(trait4))),byrow=FALSE,nrow=length(trait4),ncol=3))
names(a4)<-c("trait","mapper1","mapper2")

a5<-data.frame(matrix(c(trait5,rep("everyone",length(trait5)),rep(NA,length(trait5))),byrow=FALSE,nrow=length(trait5),ncol=3))
names(a5)<-c("trait","mapper1","mapper2")

a<-do.call(rbind,list(a1,a2,a3,a4,a5))

m<-merge(b,a,by.x="OpenGWAS.Trait",by.y="trait",all.y=TRUE)

m[,"exact mapping"]<-""
m[,"broad mapping"]<-""
m[,"narrow mapping"]<-""
m[,"inadequate"]<-""
m[,"incorrect"]<-""
m[,"Exact"]<-""
m[,"non-EFO"]<-""
m[,"comments"]<-""

vabistsevits<-m[which(m$mapper2 == "Marina Vabistsevits" | m$mapper1=="everyone"),!names(m) %in% c("mapper1","mapper2")]
centorame<-m[which(m$mapper2 == "Giulio Centorame" | m$mapper1=="everyone"),!names(m) %in% c("mapper1","mapper2")]
carnegie<-m[which(m$mapper2 == "Rebecca Carnegie" | m$mapper1=="everyone"),!names(m) %in% c("mapper1","mapper2")]
sobczykbarad<-m[which(m$mapper2 == "Maria Sobczyk-Barad" | m$mapper1=="everyone"),!names(m) %in% c("mapper1","mapper2")]

woolf<-m[which(m$mapper1 == "Benjamin Woolf" | m$mapper1=="everyone"),!names(m) %in% c("mapper1","mapper2")]
neaves<-m[which(m$mapper1 == "Samuel Neaves" | m$mapper1=="everyone"),!names(m) %in% c("mapper1","mapper2")]
thornton<-m[which(m$mapper1 == "Zak Thornton" | m$mapper1=="everyone"),!names(m) %in% c("mapper1","mapper2")]
langdon<-m[which(m$mapper1 == "Ryan Langdon" | m$mapper1=="everyone"),!names(m) %in% c("mapper1","mapper2")]

write.table(vabistsevits,"~/OpenGWAS/ontology_mapping_project/data/vabistsevits.txt",sep="\t",col.names=TRUE,row.names=FALSE,quote=FALSE)

write.table(centorame,"~/OpenGWAS/ontology_mapping_project/data/centorame.txt",sep="\t",col.names=TRUE,row.names=FALSE,quote=FALSE)

write.table(carnegie,"~/OpenGWAS/ontology_mapping_project/data/carnegie.txt",sep="\t",col.names=TRUE,row.names=FALSE,quote=FALSE)
head(sobczykbarad)
write.table(sobczykbarad,"~/OpenGWAS/ontology_mapping_project/data/sobczykbarad.txt",sep="\t",col.names=TRUE,row.names=FALSE,quote=FALSE)

write.table(woolf,"~/OpenGWAS/ontology_mapping_project/data/woolf.txt",sep="\t",col.names=TRUE,row.names=FALSE,quote=FALSE)

write.table(neaves,"~/OpenGWAS/ontology_mapping_project/data/neaves.txt",sep="\t",col.names=TRUE,row.names=FALSE,quote=FALSE)

write.table(thornton,"~/OpenGWAS/ontology_mapping_project/data/thornton.txt",sep="\t",col.names=TRUE,row.names=FALSE,quote=FALSE)

write.table(langdon,"~/OpenGWAS/ontology_mapping_project/data/langdon.txt",sep="\t",col.names=TRUE,row.names=FALSE,quote=FALSE)

save.image(file="~/OpenGWAS/ontology_mapping_project/data/traits_ontology_mapping.RData")

load("~/OpenGWAS/ontology_mapping_project/data/traits_ontology_mapping.RData")

write.table(m,"~/OpenGWAS/ontology_mapping_project/data/master_mapping_ontology_gwas_latest.txt",sep="\t",row.names=FALSE,col.names=TRUE,quote=FALSE)

