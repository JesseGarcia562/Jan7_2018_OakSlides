library(tidyverse)
library(data.table)
library(GenomicRanges)
library(Biostrings)
library(furrr)
library(glue)


plan(multiprocess)

SGETaskID<-parse_integer(Sys.getenv("SGE_TASK_ID"))

sampleTheseRows<-seq(1,129162,by=618)

start=sampleTheseRows[SGETaskID]
end=sampleTheseRows[SGETaskID+1]

if (SGETaskID == 209){
	start=128753
	end=129162
}

cat(start, "\n", end)

wholeCoordinatesAndAlignments<-"../data/CoordinatesAndAlignmentsForQRoburAndQLobata_Oct172018.csv"


#CSV has "" which represent NA. Change all "" to NA
wholeCoordinatesAndAlignments<-as_tibble(fread(wholeCoordinatesAndAlignments)) %>%
  mutate_all(funs(na_if(., ""))) %>% 
  filter(!is.na(QLobata2018SeqAlignments))




#sampledCoordinatesAndAlignments<-wholeCoordinatesAndAlignments %>% sample_n(100)


sampledCoordinatesAndAlignments<-wholeCoordinatesAndAlignments[start:end,]


getValuesNeededForDivergence<-function(qLobataSequence, qRoburSequence, qLobata2018Start, qLobata2018Name, qLobata2018End){
pairAlign=pairwiseAlignment(pattern=qLobataSequence,subject=qRoburSequence, type="global")

numberOfMatches<-nmatch(pairAlign)
numberOfMismatches<-nmismatch(pairAlign)
#mismatch<-as_tibble(mismatchTable(pairAlign))
valuesNeededForDivergence<-tibble(
  numberOfMatches=numberOfMatches,
  numberOfMismatches=numberOfMismatches, 
  pattern=as.character(pairAlign@pattern),
  subject=as.character(pairAlign@subject),
  QLobata2018Start=qLobata2018Start,
  QLobata2018Name=qLobata2018Name,
  QLobata2018End=qLobata2018End,
  totalLengthAligned=(numberOfMatches+numberOfMismatches)
)
return(valuesNeededForDivergence)
}


possibly_getValuesNeededForDivergence<-possibly(getValuesNeededForDivergence, tibble(numberOfMatches=NA,numberOfMismatches=NA, pattern=NA, subject=NA, QLobata2018Start=NA, QLobata2018Name=NA, QLobata2018End=NA ) )



l <- list(qLobataSequence = sampledCoordinatesAndAlignments$QLobata2018SeqAlignments,
          qRoburSequence = sampledCoordinatesAndAlignments$QRoburSeqAlignments, 
          qLobata2018Start = sampledCoordinatesAndAlignments$QLobata2018Start, 
          qLobata2018Name=sampledCoordinatesAndAlignments$QLobata2018Names, 
          qLobata2018End=sampledCoordinatesAndAlignments$QLobata2018End)

valuesNeededForDivergence=future_pmap(l,getValuesNeededForDivergence,.progress=T)




valuesNeededForDivergence<-valuesNeededForDivergence %>% bind_rows()

fwrite(valuesNeededForDivergence, glue("../data/{SGETaskID}_DivergenceOct18.csv"))
