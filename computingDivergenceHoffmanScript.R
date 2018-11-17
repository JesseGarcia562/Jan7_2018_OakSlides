library(tidyverse)
library(glue)
library(Biostrings)
library(data.table)
library(furrr)
library(GenomicRanges)

plan(multiprocess)
computeDivergence <- function(qLobataSequence,qRoburSequence){
  
  qLobataSequence<-unlist(str_split(string=qLobataSequence,pattern = ""))
  
  
  qRoburSequence<-unlist(str_split(string=qRoburSequence,pattern = ""))
  
  
  pairwiseAlignmentDf<-
    tibble(
      qLobataSequence=qLobataSequence,
      qRoburSequence=qRoburSequence
    )
  
  
  
  
  pairwiseAlignmentDf<-pairwiseAlignmentDf %>% 
    mutate(qLobataN=str_detect(qLobataSequence, "n|N"), 
           qRoburN=str_detect(qRoburSequence, "n|N"), 
           qLobataInsertion=str_detect(qRoburSequence, "\\."),
           qRoburInsertion=str_detect(qLobataSequence, "\\."),
    )
  
  pairwiseAlignmentDfFiltered<-pairwiseAlignmentDf %>% filter(qLobataN == FALSE, qRoburN == FALSE, qLobataInsertion == FALSE, qRoburInsertion == FALSE)
  
  filteredAlignedSequence<-nrow(pairwiseAlignmentDfFiltered)
  
  matches<-sum(pairwiseAlignmentDfFiltered$qLobataSequence == pairwiseAlignmentDfFiltered$qRoburSequence)
  mismatches<-sum(pairwiseAlignmentDfFiltered$qLobataSequence != pairwiseAlignmentDfFiltered$qRoburSequence)
  
  
  divergenceMetadata<-
    tibble(
      matches=matches,
      mismatches=mismatches,
      qLobataN=sum(pairwiseAlignmentDf$qLobataN),
      qRoburN=sum(pairwiseAlignmentDf$qRoburN),
      qLobataInsertion=sum(pairwiseAlignmentDf$qLobataInsertion),
      qRoburInsertion=sum(pairwiseAlignmentDf$qRoburInsertion),
      unfilteredAlignmentLength=nrow(pairwiseAlignmentDf),
      filteredAlignmentLength=filteredAlignedSequence
    )
  
  return(divergenceMetadata)
}
possibly_computeDivergence<-possibly(computeDivergence, otherwise = as_tibble(NA))

## Reading in Q Robur bed file of repeats and N

qRoburRepeats<-"../data/Qrob_PM1N.runs-of-SJCdeNovoRptModelRptMask-and-Ns.UCSCbed4.txt"
qRoburRepeats<-fread(qRoburRepeats)
qRoburRepeats <- qRoburRepeats %>% dplyr::rename(QRoburName=V1, Start=V2, End=V3, Annotation=V4)
qRoburRepeatsAndNGRange<-GRanges(seqnames=qRoburRepeats$QRoburName,IRanges(start=qRoburRepeats$Start, end=qRoburRepeats$End), Annotation=qRoburRepeats$Annotation)

files<-list.files("../data/", "alignmentFile", full.names = T)



computeDivergenceWithFileName<-function(filename, qRoburRepeatsAndNGRange){


df<-  as_tibble(fread(filename, sep= "\n", header = FALSE)[[1L]])


df$alignment<-df$value %>%   map_lgl(~ str_detect(.x, "^[0-9]+\\s+[atcgnATCGN\\.]") ) 
df<-df %>% unnest(alignment) 
numberOfAlignments<-sum(df$alignment)/2

####Extracting Scaffolds
qLobata2017Name<-str_split(string=str_squish(df$value[4]),pattern= " ",simplify = T )[4]
qRoburName<-str_split(string=str_squish(df$value[4]),pattern= " ",simplify = T )[6]




#####Creating seperate df for each species. 
species<-rep(c("QLobata", "QRobur") , times=numberOfAlignments  )
allAlignments<-df %>% filter(alignment==TRUE) %>% mutate(species=species, value=str_squish(value))
qLobataAlignments<-allAlignments %>% 
  filter(species=="QLobata") %>% 
  separate(value, sep=" ", into=c("QLobata2017Start", "sequence") , convert=TRUE) %>%
  mutate(qLobata2017Name=qLobata2017Name, sequenceLength=str_length(sequence))

qRoburAlignments<-allAlignments %>% 
  filter(species=="QRobur")%>% 
  separate(value, sep=" ", into=c("QRoburStart", "sequence"), convert=TRUE) %>%
  mutate(qRoburName=qRoburName, sequenceLength=str_length(sequence))






## Annotating Q Robur Alignments with Repeat or not. If repeat in Q Robur, probably repeat in Q Lobata. 




qRoburAlignmentsRanges<-GRanges(seqnames=qRoburAlignments$qRoburName, IRanges(start=qRoburAlignments$QRoburStart, end=qRoburAlignments$QRoburStart + qRoburAlignments$sequenceLength))

notInARepeatOrN<-qRoburAlignmentsRanges %outside% qRoburRepeatsAndNGRange 

qRoburAlignments$notInARepeatOrN<-notInARepeatOrN

qLobataAlignments$notInARepeatOrN<-notInARepeatOrN





## Now just subset alignments that aren't a repeat or in a run of N and compute hamming distance




qRoburAlignmentsFiltered<-qRoburAlignments %>% filter(notInARepeatOrN == TRUE)
qLobataAlignmentsFiltered<-qLobataAlignments %>% filter(notInARepeatOrN == TRUE)





divergence=map2_df(.x=qLobataAlignmentsFiltered$sequence, .y=qRoburAlignmentsFiltered$sequence, ~ possibly_computeDivergence(qLobataSequence = .x, qRoburSequence = .y) )
return(divergence)
}

possibly_computeDivergenceWithFileName<-possibly(computeDivergenceWithFileName, otherwise = as_tibble(NA))




test=files %>% future_map(~possibly_computeDivergenceWithFileName(filename=.x,qRoburRepeatsAndNGRange=qRoburRepeatsAndNGRange), .progress=T)


alignments<-tibble(
  files=files, 
  metadata=test
)

alignments<-alignments %>% unnest(metadata)


#saveRDS(alignments, "../data/November6AlignmentMetadata.rds", compress=F)
