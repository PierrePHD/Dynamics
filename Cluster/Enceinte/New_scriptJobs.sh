#!/bin/sh

	#mkdir /data1/nargil/resultats/2015/stagnants/Tot_JOB
	sed -e "s/%exit/exit/g" Calcul/main.m > TempMain1.m
	
	
	count=11;

	for Tstep in 50 # 400 200 100 50 25 10 5 #
	do
		sed -e "s/dt = 400/dt = $Tstep/g" TempMain1.m > TempMain2.m
		AugmentCore=100;		
	for cas in 2 #8
	do
		
		sed -E "s/cas\.type = [1-8];/cas.type = $cas;/g" TempMain2.m > TempMain3.m
		
	for schem in 4 #`seq 3 5` 
	do
		
		sed -E "s/schem\.type = [3-6];/schem.type = $schem;/g" TempMain3.m > TempMain4.m
		
	for Tcharge in 200 #40 60 80 120 160 200 250
	do
		
		sed -e "s/cas.T = 80/cas.T = $Tcharge/g" TempMain4.m > TempMain5.m
		
		
		
			mv TempMain5.m "main_$count.m"
		ecrire=1;
		if [ "$ecrire" -eq 1 ]
		then
			echo "rsync -ravz --exclude='*.mat' master:/home/nargil/Calcul  /usrtmp/nargil/" > job
			echo "mv /usrtmp/nargil/Calcul /usrtmp/nargil/Calcul_$count" >> job
			echo "scp master:/home/nargil/main_$count.m  /usrtmp/nargil/Calcul_$count" >> job
			echo "cd /usrtmp/nargil/Calcul_$count/" >> job
			echo "/usr/local/MATLAB-R2012b/bin/matlab -nodisplay -r main_$count > Log_cas_${cas}_schem_${schem}_Tcharge_${Tcharge}_Tstep_${Tstep}" >> job
			echo "mkdir /data1/nargil/resultats/2015/stagnants/JOB_cas_${cas}_schem_${schem}_Tcharge_${Tcharge}_Tstep_${Tstep}/" >> job
			echo "mkdir /data1/nargil/resultats/2015/stagnants/JOB_cas_${cas}_schem_${schem}_Tcharge_${Tcharge}_Tstep_${Tstep}/Images/" >> job
			echo "cp /usrtmp/nargil/Calcul_$count/Images/Sortie/*.eps /data1/nargil/resultats/2015/stagnants/JOB_cas_${cas}_schem_${schem}_Tcharge_${Tcharge}_Tstep_${Tstep}/Images/" >> job
			echo "cp /usrtmp/nargil/Calcul_$count/Images/Sortie/matPGDErreur.png /data1/nargil/resultats/2015/stagnants/Tot_JOB/Erreur_cas_${cas}_schem_${schem}_Tcharge_${Tcharge}_Tstep_${Tstep}.png" >> job
			echo "cp /usrtmp/nargil/Calcul_$count/Log* /data1/nargil/resultats/2015/stagnants/JOB_cas_${cas}_schem_${schem}_Tcharge_${Tcharge}_Tstep_${Tstep}/" >> job
			echo "cp /usrtmp/nargil/Calcul_$count/*.mat /data1/nargil/resultats/2015/stagnants/JOB_cas_${cas}_schem_${schem}_Tcharge_${Tcharge}_Tstep_${Tstep}/Res_cas_${cas}_schem_${schem}_Tcharge_${Tcharge}_Tstep_${Tstep}.mat" >> job
			echo "rm -r /usrtmp/nargil/Calcul_$count" >> job
			mv job "job_cas_${cas}_schem_${schem}_Tcharge_${Tcharge}_Tstep_${Tstep}"
		fi
		
		T0=60;
		Secu=2;
		TT=`echo "sqrt((400/$Tstep)^3)" | bc`;
		Tf=$(( $TT * $T0 * $Secu )) ;
		echo Tf
		echo "temps de calcul (400/$Tstep)* $T0 * $Secu  = $Tf"
		if [ $Tf -ge 60 ]
			then
			Th=$(($Tf/60));
			Tm=$(($Tf%60));
			Th=$( printf "%02d" $Th )
			Tm=$( printf "%02d" $Tm )
		else
			Th="00";
			Tm=$Tf;
			Tm=$( printf "%02d" $Tm )
		fi
		
		#### enlever echo
		
		#if [ "$Tstep" -le "$AugmentCore" ]
		#then
		#	qsub -l nodes=01:ppn=12,walltime=$Th:$Tm:00,pvmem=8gb "job_cas_${cas}_schem_${schem}_Tcharge_${Tcharge}_Tstep_${Tstep}"
		#else
		#	qsub -l nodes=01:ppn=8,walltime=$Th:$Tm:00,pvmem=4gb "job_cas_${cas}_schem_${schem}_Tcharge_${Tcharge}_Tstep_${Tstep}"
		#fi
		
		
		# >> SortieQsub
		
		count=$(($count+1));
		
	done
	
	done
	
	done

	done

#done

rm TempMain*.m
