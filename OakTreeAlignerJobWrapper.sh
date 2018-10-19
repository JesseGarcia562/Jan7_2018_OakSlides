#!/bin/bash

#$ -cwd
#$ -l h_rt=00:10:00,h_data=20G
#$ -j y
#$ -t 1-209:1
. /u/local/Modules/default/init/modules.sh
module load gcc/4.9.3
module load R/3.5.0

R CMD BATCH --no-save --no-restore OakTreeAligner_02.R ../data/${SGE_TASK_ID}.Rout