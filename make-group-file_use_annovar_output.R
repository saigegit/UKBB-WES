#!/usr/bin/env Rscript



###marker id is chr:pos:ref:alt
options(stringsAsFactors=F)
print(sessionInfo())


library(optparse)
library(data.table)
library(methods)

option_list <- list(
  make_option("--chr", type="character",default="",
    help="chromosome."), 
  make_option("--inputfile", type="character", default="",
    help="annovar output"),
  make_option("--outputfile", type="character", default="",
    help="group file")
  )

parser <- OptionParser(usage="%prog [options]", option_list=option_list)

args <- parse_args(parser, positional_arguments = 0)
opt <- args$options
print(opt)

chr=opt$chr

  splitforPos = function(x){
	y = strsplit(x, split=":")[[1]][2]
  	return(y)
  }
  reWriteChrPos = function(x){
	a = strsplit(x, split=":")[[1]]
  	y = paste0(a[1],":",a[2],"_",a[3],"/",a[4])
        return(y)
  }
		    
## Similar to SKAT-O in AJHG, we use the following annotation to make group-v1
## frameshift deletion, frameshift insertion, nonframeshift deletion, nonframeshift insertion, nonsynonymous SNV, splicing, stopgain, and stoploss

missenseList = c("nonsynonymous SNV")
synonymousList = c("synonymous SNV")
lofList = c("frameshift deletion", "frameshift insertion",
                  "nonframeshift deletion", "nonframeshift insertion",
                  "splicing", "stopgain", "stoploss")
combineList = c(missenseList, synonymousList, lofList)
combineList = unique(combineList)

  Data1 = data.table::fread(opt$inputfile)
  Data1 = Data1[,c("Gene.refGene", "ExonicFunc.refGene", "Otherinfo", "Func.refGene", "Start")]
  Data1 = Data1[which( (Data1$ExonicFunc.refGene %in% combineList ) | (Data1$Func.refGene  %in% combineList )), , drop=F]
  rowswithDupGeneNames =  grep(";", Data1$Gene.refGene)
  if(length(rowswithDupGeneNames) > 0){
  	Data2 = Data1[-rowswithDupGeneNames, ]
  
  for(i in rowswithDupGeneNames){
	  print(i)
	a = Data1[i,, drop=F]
  	newgeneList = strsplit(a$Gene.refGene, split=";")[[1]]
	newgeneList = unique(newgeneList)
	aDF = NULL
	for(j in newgeneList){
		a$Gene.refGene = j
		aDF = rbind(aDF, a)
	}
	Data2 = rbind(Data2, aDF)	
  }
 }else{
    Data2 = Data1
  }

  Data2 = Data2[order(Data2$Start), ]
  Data2$Group = rep("missense", nrow(Data2))
  Data2$Group[which((Data2$ExonicFunc.refGene %in% lofList) | (Data2$Func.refGene  %in% lofList ))] = "lof"
  Data2$Group[which(Data2$ExonicFunc.refGene %in% missenseList)] = "missense"
  Data2$Group[which(Data2$ExonicFunc.refGene %in% synonymousList)] = "synonymous"
  geneList = unique(Data2$Gene.refGene)

  for(gene in geneList){
	rowHeaderData = cbind(rep(gene,2), c("var", "anno"))
	geneTemp = Data2[which(Data2$Gene.refGene == gene), c("Otherinfo", "Group")]
	geneTemp$rank = 1
	geneTemp$rank[which(geneTemp$Group == "missense")] = 2
	geneTemp$rank[which(geneTemp$Group == "synonymous")] = 3
	geneTemp$pos = lapply(geneTemp$Otherinfo, splitforPos)
	geneTemp = geneTemp[order(geneTemp$rank),]
	geneTemp = geneTemp[!duplicated(geneTemp$Otherinfo), ]
	geneTemp$pos = as.numeric(geneTemp$pos)
	geneTemp2 = geneTemp[order(geneTemp$pos),]
  	geneTempt = t(geneTemp2[,1:2])
	geneTempt_new = cbind(rowHeaderData, geneTempt)
	write.table(geneTempt_new, opt$outputfile, col.names=F, row.names=F, quote=F, append=T)
  }	  


