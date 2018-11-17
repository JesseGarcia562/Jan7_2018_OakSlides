#!/bin/bash
#$ -cwd
#$ -l h_rt=24:00:00,h_data=4G,highp
#$ -pe shared 8
#$ -j y
#$ -t 1-201:1
. /u/local/Modules/default/init/modules.sh
module load gcc/4.9.3
module load R/3.5.0
module load python/3.4

R CMD BATCH --no-save --no-restore RunMSMCOnBootstrapsV2.R ../data/${SGE_TASK_ID}_Fixed.Rout