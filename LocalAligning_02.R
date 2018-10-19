library(tidyverse)
library(data.table)
library(GenomicRanges)
library(Biostrings)
library(furrr)


plan(multiprocess)

wholeCoordinatesAndAlignments<-"../data/CoordinatesAndAlignmentsForQRoburAndQLobata_Oct172018.csv"


#CSV has "" which represent NA. Change all "" to NA
wholeCoordinatesAndAlignments<-as_tibble(fread(wholeCoordinatesAndAlignments)) %>%
  mutate_all(funs(na_if(., ""))) %>% 
  filter(!is.na(QLobata2018SeqAlignments))




sampledCoordinatesAndAlignments<-wholeCoordinatesAndAlignments 


getValuesNeededForDivergence<-function(qLobataSequence, qRoburSequence){
pairAlign=pairwiseAlignment(pattern=qLobataSequence,subject=qRoburSequence, type="global")

numberOfMatches<-nmatch(pairAlign)
numberOfMismatches<-nmismatch(pairAlign)
#mismatch<-as_tibble(mismatchTable(pairAlign))
valuesNeededForDivergence<-tibble(
  numberOfMatches=numberOfMatches,
  numberOfMismatches=numberOfMismatches
)
return(valuesNeededForDivergence)
}


possibly_getValuesNeededForDivergence<-possibly(getValuesNeededForDivergence, tibble(numberOfMatches=NA,numberOfMismatches=NA ))


hold=future_map2(sampledCoordinatesAndAlignments$QLobata2018SeqAlignments,sampledCoordinatesAndAlignments$QRoburSeqAlignments, ~ getValuesNeededForDivergence(.x,.y) , .progress=T)
