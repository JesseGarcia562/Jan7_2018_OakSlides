#QRob MSMC with --chromL to be mean callable sites for QRob 25796258


#! /bin/bash
#$ -cwd
#$ -l h_rt=24:00:00,h_data=16G
#$ -N QRobMSToMSMCChromLSetToMean
#$ -m abe


#python3 msmc2ms.py --chromL 25796258 /u/flashscratch/j/jessegar/forJesse/Qrob_PSMC/output_20180802/oak.msmc.out


#Simulating QRob Mean callable site per chr 25796258. Therefore, we are setting "--chromL" to 25796258 in msmc2ms.py script. 
#nsam is set to 2 in ms. nrep is set to 12 to simulate 12 chromosomes. 
/u/flashscratch/j/jessegar/msdir/ms 2 12 -T -t 29446.774653836055 -r 11524.5586630206 25796258 -p 8 -eN 0.081270879954 1.8599975158418163 -eN 0.16465334262 4.079690960021795 -eN 0.25025899422 6.52106432631003 -eN 0.33821065416 8.058264037088822 -eN 0.42863972693999997 8.57100926048225 -eN 0.52169075751 8.428227823744468 -eN 0.61751967921 7.985906633727449 -eN 0.7162973178900001 7.4645955111709466 -eN 0.81821202 6.978400360060382 -eN 0.9234670245 6.428186190879772 -eN 1.1449361688 6.068854196614443 -eN 1.3828221153 6.053484434923815 -eN 1.6397617143 6.254207702549786 -eN 1.9190751195 6.5804823268269415 -eN 2.2250198367 6.993358133891079 -eN 2.5632374991 7.486060253884969 -eN 2.9413232868 8.07077346870149 -eN 3.3699560055 8.778559403559402 -eN 3.8647903113 9.671340251711195 -eN 4.4500484337 10.869667717199793 -eN 5.1663431235 12.628005535374502 -eN 6.089810148 15.584949297278063 -eN 7.3913629601999995 21.83091834992817 -eN 9.616356516 33.09807803473668 > ../data/QRobMSToMSMCChromLSetToMean_ms.out.txt