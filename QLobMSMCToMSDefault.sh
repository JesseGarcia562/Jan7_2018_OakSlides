#QLob MSMC with default --chromL and nrep = 12


#! /bin/bash
#$ -cwd
#$ -l h_rt=24:00:00,h_data=16G
#$ -N QLobMSToMSMCDefault
#$ -m abe



#python3 msmc2ms.py /u/flashscratch/j/jessegar/forJesse/Qlob_PSMC/output_20180613/oak.msmc.out


/u/flashscratch/j/jessegar/msdir/ms 2 12 -T -t 519.2418031190855 -r 180.52044631125324 1000000 -p 6 -eN 0.11960554721700001 3.148671625929862 -eN 0.24231870246999998 4.003015951703202 -eN 0.36830239563 4.792457525366578 -eN 0.49774112647999996 5.010771460313413 -eN 0.63082363175 4.933429309547627 -eN 0.76776561056 4.831471667346107 -eN 0.908796243225 4.839527175592853 -eN 1.05416782068 5.008660350419103 -eN 1.204153818595 5.355877007704747 -eN 1.359056600915 6.252162903566153 -eN 1.68499145243 8.02131230840997 -eN 2.0350826795 10.329618167482822 -eN 2.4132301992499996 12.84565616141404 -eN 2.8242718348 15.215366383567055 -eN 3.2745437478 17.193099138508234 -eN 3.77228872605 18.711628426662262 -eN 4.32871542025 19.905993860401658 -eN 4.959539052 21.08663995094819 -eN 5.68777394705 22.732085315329137 -eN 6.5490874956 25.611194595529074 -eN 7.603259168049999 31.203075128400386 -eN 8.962298436 42.997526266672025 -eN 10.877783657 71.16670854642742 -eN 14.1523274048 116.67328016284345 > ../data/QLobMSToMSMCDefault_ms.out.txt