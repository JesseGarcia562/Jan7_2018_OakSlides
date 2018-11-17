
# in python 2.7
# This is to set up a MACS script to simulate the full demographic history of Qlob or Qrob
# want to make generic
# input
# spp
# mu
# Len
# 
#import numpy as np
import pandas as pd

import argparse
parser = argparse.ArgumentParser(description='Make a macs simulation from msmc')
parser.add_argument("--mu",required=True,help="supply mutation rate in mutation/bp/gen")
args = parser.parse_args()

mu= float(2.5e-09)

r = 2.54e-08 # Prunus persica (peach) Euchromatin recombination rate


##simulate whole chromosome, not just windows, to do psmc and pi
Len =  25796258 # mean callable sites per chr for Qrob
num=12 #  this is the total number of chunks you want to simulate 
blocksPerGroup=12


groups=num/blocksPerGroup
## Qrob
input=pd.read_table("/u/flashscratch/j/jessegar/PSMCTroubleShooting/MaxIterationsTo100/Qrob.oak.msmc.out.final.txt")

# to get diploids from lamba: (1/lamba)/(2*mu) and then scale by ancestral size
diploids=tuple((1/x)/(2*mu) for x in input.lambda_00)
Na = diploids[-1] # ancestral size 
# scale it relative to oldest time in inference (could also do most recent size, just be consistent)
diploids_Na = diploids/Na # this is now relative to ancient size, so is ready for macs

times_gen = tuple(x/mu for x in input.left_time_boundary) # this gives time in generations (if you wanted years woudl multiply by 4 yrs/gen)
times_gen_4Na = times_gen / (4*Na)
# if first time is -0, make it just 0.
times_gen_4Na[0]=0 # set first time to zero if its -0. 

ss=2 # two haplotypes (one genome)
theta = 4*Na*mu
rho = 4 * Na*r
# Note that theta will be the same across different values of Mu for the same
# models, because mutation rate changes scaling of MSMC and so alters Na, but then
# theta = 4Namu = 4 (1/(lamba*2mu))*mu = 2/lamba [is this right?]
############################## WRITE SCRIPT ################
print("#!/bin/bash")
print("#$ -cwd")
print("#$ -l h_rt=2:00:00,h_data=2G,highp")

print("#$ -N Qrob_macs")
print("#$ -m abe")
#print("#$ -t 1-70")
#print("j=$SGE_TASK_ID")
#print("for j in {1.."+str(numGroups)+"}")
#print("do")
print("")
print("source /u/local/Modules/default/init/modules.sh")
print("module load gcc/4.9.3") #need to load gcc otherwise won't run

print("rundate=`date +%Y%m%d`")

#print("model=Qlob.psmc."+str(mu))
print("model=Qrob.psmc."+str(mu))
print("mkdir -p ${model}")
print("for j in {1.."+str(groups)+"}") 
# simulate slightly more than you need 
print("do")
print("mkdir -p ${model}/group_$j.${model}")

print("cd ${model}/group_$j.${model}")
print("for i in {1.."+str(blocksPerGroup)+"}")
print("do")

print("# Qrob psmc' model")
print("mu="+str(mu))
print("r="+str(r))
print("Na="+str(Na))
print("rho=" +str(rho))
print("theta="+str(theta))
print("date=`date +%Y%m%d`")
print("SEED=$((date+$RANDOM+((j-1)*"+str(blocksPerGroup)+")+i))") 
# this is a new addition! need to have a different random seed for each simulation; if they start within a second of each other, they will have the same seed. not an issue for big simulations of 30Mb because those are 
#slow, but 100kb can start within a second of each other!")
print("/u/flashscratch/j/jessegar/macs/ " +str(ss) +" "+str(Len)+" -t "+str(theta)+" -r "+str(rho)+" -s $SEED")
for x, y in zip(times_gen_4Na,diploids_Na):
    print("-eN " + str(x)+" "+str(y))

print(" > group_${j}_block_${i}.${model}.macsFormat.OutputFile.${rundate}.txt")


#print("| ./msformatter > asianSample/group_${j}_block_${i}.smcpp.chb.macs.msFormat.OutputFile.${rundate}.txt"),
print("")
print("/u/flashscratch/j/jessegar/macs/msformatter < group_${j}_block_${i}.${model}.macsFormat.OutputFile.${rundate}.txt > group_${j}_block_${i}.${model}.msFormat.OutputFile.${rundate}.txt")
###################################################
print("done")
print("cd ../../")
print("done")