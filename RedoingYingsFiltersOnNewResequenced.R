library(data.table)
library(tidyverse)
library(glue)
library(bedr)

## Step 1. Remove indels, multiallelics, remove repeats. Run on Hoffman

SGETaskID<-parse_integer(Sys.getenv("SGE_TASK_ID"))


vcftools<-"vcftools"
resequencedVCF<-"/u/flashscratch/j/jessegar/forJesse/SorelNewResequenced"
qLobataRepeatsBed<-"/u/flashscratch/j/jessegar/forJesse/data_from_sorel/Qlobata.v3.0.repeats.bed"
outputDir<-"/u/flashscratch/j/jessegar/FilteringResequence"

filters<-tibble(
  chromosome=1:12,
  vcftools=vcftools,
  resequencedVCF=glue("{resequencedVCF}/2018wgs3.chr{chromosome}.vcf.gz"),
  qLobataRepeatsBed=qLobataRepeatsBed
)


filters<-filters %>% 
  mutate(output=glue("{outputDir}/2018wgs3.ef.rmIndelRepeats.chr{chromosome}")) %>%
  mutate(command=glue("{vcftools} --gzvcf {resequencedVCF} --remove-indels --recode --recode-INFO-all --chr chr{chromosome} --exclude-bed {qLobataRepeatsBed} --min-alleles 1 --max-alleles 2 --out {output}"))



system(filters$command[SGETaskID])



## Step 2. Removing upstream Indels

filters<-filters %>% 
  mutate(commandToRemoveUpstreamIndels=glue("grep -vw '\\*' {output}.recode.vcf > {outputDir}/2018wgs3.ef.rmIndelRepeatsStar.chr{chromosome}.vcf" )   ) 

system(filters$commandToRemoveUpstreamIndels[SGETaskID])


## Step 3. Extracting individual and filter by min depth 12x
vcftools<-"vcftools"
resequencedVCF<-"/u/flashscratch/j/jessegar/forJesse/SorelNewResequenced"
qLobataRepeatsBed<-"/u/flashscratch/j/jessegar/forJesse/data_from_sorel/Qlobata.v3.0.repeats.bed"
outputDir<-"/u/flashscratch/j/jessegar/FilteringResequence"

individuals<-c("QL.BER.1.00F",
"QL.CHE.100X.00F",
"QL.CHI.3b.00F",
"QL.CLO.4.00F",
"QL.CVD.8.00F",
"QL.FHL.5.00F",
"QL.GRV.2.00F",
"QL.GRV.7.00F",
"QL.HV.1.00F",
"QL.JAS.5.00F",
"QL.LAY.5.00F",
"QL.LAY.6.00F",
"QL.LYN.4.00F",
"QL.MAR.B.00F",
"QL.MCK.5.00F",
"QL.MOH.3.00F",
"QL.MTR.3.00F",
"QL.PEN.5.00F",
"QL.ROV.3.00F",
"QL.SUN.5.00F",
"QL.UKI.5.00F",
"QL.WLT.2.00F")




filters<-tibble(
  vcftools=vcftools,
  individual=individuals
)


filters$chromosome<-filters$individual %>% map(~1:12)

filters<-filters %>% unnest(chromosome)




filters<-filters %>%
  mutate(input=glue("{outputDir}/2018wgs3.ef.rmIndelRepeatsStar.chr{chromosome}.vcf")) %>%
  mutate(output=glue("{outputDir}/{individual}.2018wgs3.ef.rmIndelRepeatsStar.chr{chromosome}.minDP12"  ))



filters<-filters %>% 
  mutate(extractingIndividual=glue("{vcftools} --vcf {input} --indv {individual} --min-meanDP 12 --recode --recode-INFO-all --out {output}" )   )  
  

system(filters$extractingIndividual[SGETaskID])


## Step 4 Convert this vcf to bed file for the masks
vcftools<-"vcftools"
bedtools<-"bedtools"
qLobataRepeatsBed<-"/u/flashscratch/j/jessegar/forJesse/data_from_sorel/Qlobata.v3.0.repeats.bed"
outputDir<-"/u/flashscratch/j/jessegar/FilteringResequence"





individuals<-c("QL.BER.1.00F",
"QL.CHE.100X.00F",
"QL.CHI.3b.00F",
"QL.CLO.4.00F",
"QL.CVD.8.00F",
"QL.FHL.5.00F",
"QL.GRV.2.00F",
"QL.GRV.7.00F",
"QL.HV.1.00F",
"QL.JAS.5.00F",
"QL.LAY.5.00F",
"QL.LAY.6.00F",
"QL.LYN.4.00F",
"QL.MAR.B.00F",
"QL.MCK.5.00F",
"QL.MOH.3.00F",
"QL.MTR.3.00F",
"QL.PEN.5.00F",
"QL.ROV.3.00F",
"QL.SUN.5.00F",
"QL.UKI.5.00F",
"QL.WLT.2.00F")




filters<-tibble(
  vcftools=vcftools,
  individual=individuals
)


filters$chromosome<-filters$individual %>% map(~1:12)

filters<-filters %>% unnest(chromosome)


filters<-filters %>% 
mutate(inputVCF=glue("{outputDir}/{individual}.2018wgs3.ef.rmIndelRepeatsStar.chr{chromosome}.minDP12.recode.vcf")) %>%
mutate(outputBed=glue("{outputDir}/{individual}.2018wgs3.ef.rmIndelRepeatsStar.chr{chromosome}.minDP12.bed"))


vcf2mergedBed<-funtion(inputVCF, outputBed){

x=read.vcf(inputVCF)
bed<-as_tibble(vcf2bed(x))
bed$V3 <- bed$V2 + 1
bedMerged=as_tibble(bedr.merge.region(bed, check.chr = FALSE,check.valid = FALSE,check.sort = FALSE, check.zero.based = FALSE, list.names = FALSE))
write_tsv(bedMerged, path=outputBed,col_names=FALSE)


}

map2(.x= filters$inputVCF, .y=filters$outputBed, .f=vcf2mergedBed)


