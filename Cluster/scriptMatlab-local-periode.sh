#!/bin/sh
    
cd /Users/pierrephd/Dropbox/Travail/Git/PierrePHD/Dynamics/Matlab   


	sed -e "s/%exit/exit/g" main.m > TempMain1.m
	
	for cas in 2 8
	do
		
		sed -E "s/cas\.type = [1-8];/cas.type = $cas;/g" TempMain1.m > TempMain2.m
		
	for schem in `seq 3 5` 
	do
		
		sed -E "s/schem\.type = [3-6];/schem.type = $schem;/g" TempMain2.m > TempMain3.m
		
	for iter in 120 160 200 250 #40 60 80 
	do
		
		sed -e "s/cas.T = 80/cas.T = $iter/g" TempMain3.m > TempMain4.m
		
		/Applications/MATLAB_R2012a.app/bin/matlab -nodesktop -nodisplay -r TempMain4 > Log
		cp Log "Log$iter"
		#mv OutPut.mat "OutCas8schem$iter.mat"
		
		cd ../Latex/Auto/
		
		for meth in POD PGD
		do
			sed -e "s/TitreRemplacable/Cas=$cas Schem=$schem $meth T = $iter e-6/g" img2pdf-Spec.tex > Temp1-img2pdf-Spec.tex
			sed -e "s/mat/mat$meth/g" Temp1-img2pdf-Spec.tex > Temp2-img2pdf-Spec.tex
			
			pdflatex -shell-escape Temp2-img2pdf-Spec.tex
			mv Temp2-img2pdf-Spec.pdf ../../Matlab/Images/Sortie/2pdf/"$meth"_T"$iter.pdf"
			rm Temp*-img2pdf-Spec.*
		done
		
		cd ../../Matlab/
		
	done
	
		mkdir Images/Sortie/2pdf/Schem"$schem"
		mv Images/Sortie/2pdf/*_T*.pdf Images/Sortie/2pdf/Schem"$schem"/
	
	done

		mkdir Images/Sortie/2pdf/PetitDtCas"$cas"
		mv Images/Sortie/2pdf/Schem* Images/Sortie/2pdf/PetitDtCas"$cas"
	
	done		

#done

rm TempMain*.m 