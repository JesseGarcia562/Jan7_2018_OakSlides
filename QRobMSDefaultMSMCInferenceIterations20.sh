#This script is going to do default MSMC' on simulated ms data with default chromL. 

#! /bin/bash
#$ -cwd
#$ -l h_rt=24:00:00,h_data=4G,highp
#$ -N MSQRob
#$ -pe shared 8
#$ -m abe

# run MSMC with default settings (for now)

source /u/local/Modules/default/init/modules.sh
module load python/3.4 ## has to be 3.4! otherwise won't work.


OUTDIR=/u/flashscratch/j/jessegar/PSMCTroubleShooting/TryingMSSimulations/QRobur

INPUTDIR=../data/QRobMSMCToMSDefault_msmc.in.txt






/u/home/j/jessegar/project-klohmuel/msmc-master/msmc -t 12 -i 20 -o $OUTDIR/Qrob20MSSimulated_oak.msmc.out $INPUTDIR