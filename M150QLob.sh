#This script is going to set max iterations of PSMC' to  FOR Q Lobata simulations this time!

#! /bin/bash
#$ -cwd
#$ -l h_rt=24:00:00,h_data=4G,highp
#$ -N M150Qlob
#$ -pe shared 8
#$ -m abe

# run MSMC with default settings (for now)

source /u/local/Modules/default/init/modules.sh
module load python/3.4 ## has to be 3.4! otherwise won't work.


OUTDIR=/u/flashscratch/j/jessegar/PSMCTroubleShooting/QLobataSimulationsMaxIterations

INPUTDIR=/u/flashscratch/z/zhen/forJesse/pi_sim/Qlob.psmc.2.5e-09/group_1.Qlob.psmc.2.5e-09/msmcAnalysis/inputFiles





/u/home/j/jessegar/project-klohmuel/msmc-master/msmc -t 12 -i 150 -o $OUTDIR/Qlob150_oak.msmc.out $INPUTDIR/chr*_postMultiHetSep.txt