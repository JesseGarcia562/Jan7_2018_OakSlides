library(tidyverse)
library(glue)

SGETaskID<-parse_integer(Sys.getenv("SGE_TASK_ID"))

bootstrapLocation<-"/u/flashscratch/j/jessegar/Bootstraps/"
folders<-list.dirs(bootstrapLocation, recursive = FALSE)
bootstrapNumber<-parse_number(folders)
bootstrapDF<-tibble(
  inputFolders=folders,
  number=bootstrapNumber, 
  outputFolders=folders
) %>% 
  arrange(number)



bootstrapDF<-bootstrapDF %>% 
  mutate(MSMCCommand=glue("{msmc} -t 12 -o {outputFolders}/oak.msmc.out {inputFolders}/bootstrap_multihetsep.chr*.txt")) 

glue("Command running: 
     {bootstrapDF$MSMCCommand[SGETaskID]}
     ")


system(bootstrapDF$MSMCCommand[SGETaskID])