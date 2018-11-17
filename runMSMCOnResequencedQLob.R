library(tidyverse)
library(glue)


SGETaskID<-parse_integer(Sys.getenv("SGE_TASK_ID"))


msmc<-"/u/home/j/jessegar/project-klohmuel/msmc-master/msmc"
outdir<-"/u/flashscratch/j/jessegar/forJesse/resequenced"
msmcIterations=200
resequencedMSMCDirectories<-"/u/flashscratch/z/zhen/forJesse/resequenced/msmcAnalysis"
resequencedMSMCDirectories<-list.dirs(resequencedMSMCDirectories, full.names = T) %>% str_subset(pattern="inputFiles")
msmcInput<-resequencedMSMCDirectories %>% map_chr(~list.files(path=.x, full.names = T, pattern="chr1_postMultiHetSep.txt") %>% str_replace(pattern="chr1", replacement = "chr*"))
df<-tibble(
  resequencedMSMCDirectories=resequencedMSMCDirectories,
  msmcInput=msmcInput, 
  msmcIterations=msmcIterations, 
  output=outdir
)

df$name<-resequencedMSMCDirectories %>% str_extract(pattern="QL.*00F")

df<-df %>% mutate(command=glue("{msmc} -t 12 -i {msmcIterations} -o {outdir}/{name} {msmcInput}"))

df$command[SGETaskID]

system(df$command[SGETaskID])