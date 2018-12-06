#!/bin/bash
#$ -cwd
#$ -l h_rt=24:00:00,h_data=32G
#$ -N Qrob_macs
#$ -m abe
#$ -t 1-20

source /u/local/Modules/default/init/modules.sh
module load gcc/6.3.0
module load python/3.4
rundate=`date +%Y%m%d`
model=Qrob.psmc.1.01e-08

j=$SGE_TASK_ID
mkdir -p /u/flashscratch/j/jessegar/SimulatingQRobur/Qrobur.psmc.1.01e-08/replicate_$j.${model}
cd /u/flashscratch/j/jessegar/SimulatingQRobur/Qrobur.psmc.1.01e-08/replicate_$j.${model}
for i in {1..12}
do
# Qrob psmc' model
mu=1.01e-08
r=2.54e-08
Na=3910498.08405
rho=0.39730660534
theta=0.157984122596
date=`date +%Y%m%d`

SEED=$((date+$RANDOM+((j-1)*12)+i))

/u/flashscratch/j/jessegar/macs/macs 2 29160242 -t 0.157984122596 -r 0.39730660534 -s $SEED \
-eN 0.0 0.00705610550019 \
-eN 0.000578552442475 0.0187838393251 \
-eN 0.0011721304455 0.0327377719851 \
-eN 0.001781546116 0.0477580014788 \
-eN 0.00240765333725 0.0554980776565 \
-eN 0.0030514079015 0.0559981421684 \
-eN 0.003713816239 0.0527448398843 \
-eN 0.00439600504525 0.0486858905332 \
-eN 0.0050991833025 0.0452276835795 \
-eN 0.00582469291775 0.0427587581231 \
-eN 0.0065740150525 0.0408897258084 \
-eN 0.007348713155 0.0408897258084 \
-eN 0.008150565885 0.040900822895 \
-eN 0.00898166206 0.040900822895 \
-eN 0.0098440904975 0.0426892598213 \
-eN 0.0107403198 0.0426892598213 \
-eN 0.011673198355 0.0449528970197 \
-eN 0.0126457644425 0.0449528970197 \
-eN 0.013661499425 0.0467851493784 \
-eN 0.0147245809375 0.0467851493784 \
-eN 0.0158395031025 0.0479187090962 \
-eN 0.0170116462075 0.0479187090962 \
-eN 0.01824715011 0.0485902140203 \
-eN 0.01955335732 0.0485902140203 \
-eN 0.020938686405 0.0493643985182 \
-eN 0.022413518155 0.0493643985182 \
-eN 0.023990132285 0.0511838243024 \
-eN 0.0256835936 0.0511838243024 \
-eN 0.0275127014575 0.055805106413 \
-eN 0.029501065825 0.055805106413 \
-eN 0.031679006205 0.0672286981227 \
-eN 0.03408671651 0.0672286981227 \
-eN 0.036778252805 0.09668759356 \
-eN 0.0398296353875 0.09668759356 \
-eN 0.04335220456 0.183551351461 \
-eN 0.047518572605 0.183551351461 \
-eN 0.0526177559075 0.496747080613 \
-eN 0.0591917076625 0.496747080613 \
-eN 0.0684575122 1.0 \
-eN 0.0842970786 1.0 > group_${j}_block_${i}.${model}.macsFormat.OutputFile.${rundate}.txt

/u/flashscratch/j/jessegar/macs/msformatter < group_${j}_block_${i}.${model}.macsFormat.OutputFile.${rundate}.txt > group_${j}_block_${i}.${model}.msFormat.OutputFile.${rundate}.txt
cat group_${j}_block_${i}.${model}.msFormat.OutputFile.${rundate}.txt | python3 /u/home/j/jessegar/project-klohmuel/oakTrees/code/ms2multihetsep.py chr${i} 29160242 > chr${i}_postMultiHetSep.txt



done

cd ../../

done


