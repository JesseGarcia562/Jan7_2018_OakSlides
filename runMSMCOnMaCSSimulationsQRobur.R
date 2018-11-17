library(tidyverse)
library(glue)




SGETaskID<-parse_integer(Sys.getenv("SGE_TASK_ID"))


msmc<-"/u/home/j/jessegar/project-klohmuel/msmc-master/msmc"
simulationDirectory<-"/u/flashscratch/j/jessegar/SimulatingQRoburAfter20Iterations/Qrob.psmc.2.5e-09"
simulationDirectory<-list.dirs(simulationDirectory, recursive = F)
replicate<-parse_number(str_extract(simulationDirectory, "replicate_[0-9]+"))
msmcIterations=200
simulationDf<-tibble(
    simulationDirectory=simulationDirectory,
    replicate=replicate,
    msmcIterations=msmcIterations
    ) %>% arrange(replicate)


simulationDf <- simulationDf %>% mutate(msmcInput=glue("{simulationDirectory}/chr*_postMultiHetSep.txt"))


simulationDf<-simulationDf %>% mutate(command=glue("{msmc} -t 12 -i {msmcIterations} -o {simulationDirectory}/oak.msmc.out {msmcInput}"))


qRob20IterationsSims<-simulationDf



simulationDirectory<-"/u/flashscratch/j/jessegar/SimulatingQRobur/Qrob.psmc.2.5e-09"
simulationDirectory<-list.dirs(simulationDirectory, recursive = F)
replicate<-parse_number(str_extract(simulationDirectory, "replicate_[0-9]+"))
msmcIterations=200
simulationDf<-tibble(
    simulationDirectory=simulationDirectory,
    replicate=replicate,
    msmcIterations=msmcIterations
    ) %>% arrange(replicate)


simulationDf <- simulationDf %>% mutate(msmcInput=glue("{simulationDirectory}/chr*_postMultiHetSep.txt"))


simulationDf<-simulationDf %>% mutate(command=glue("{msmc} -t 12 -i {msmcIterations} -o {simulationDirectory}/oak.msmc.out {msmcInput}"))

qRob100IterationsSims<-simulationDf


df<-bind_rows(qRob20IterationsSims,qRob100IterationsSims)


system(df$command[SGETaskID])






