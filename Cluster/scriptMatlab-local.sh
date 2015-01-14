#!/bin/sh
    
cd /Users/pierrephd/Dropbox/Travail/Git/PierrePHD/Dynamics/Matlab   


	#sed -e "s/ErrPOD = AfficherMethode(Ref,SoluPOD,MET,ME,MT,Res,NDR,NDE,OI);/Err$meth = AfficherMethode(Ref,Solu$meth,MET,ME,MT,Res,NDR,NDE,OI);/g" main.m > TempMain1.m
	
	sed -e "s/%exit/exit/g" main.m > TempMain1.m
	#sed -e "s/FR$meth = 0 ;/FR$meth = 1 ;/g" TempMain1.m > TempMain2.m
	
	for alpha in `seq 1 2`
	do

	for iter in `seq 4 5` 
	do
		
		sed -E "s/schem\.type = [3-6];/schem.type = $iter;/g" TempMain1.m > TempMain2.m
		sed -E "s/schem.alpha = [-][0-9];/schem.alpha = -$alpha;/g" TempMain2.m > TempMain1.m
		
		/Applications/MATLAB_R2012a.app/bin/matlab -nodesktop -nodisplay -r TempMain1 > Log
		cp Log "Log$iter"
		#mv OutPut.mat "OutCas8schem$iter.mat"
		
		cd ../Latex/Auto/
		#cd Images/Sortie/2pdf/
		
		for meth in POD PGD
		do
			sed -e "s/TitreRemplacable/$meth schema $iter/g" img2pdf-Spec.tex > Temp1-img2pdf-Spec.tex
			sed -e "s/mat/mat$meth/g" Temp1-img2pdf-Spec.tex > Temp2-img2pdf-Spec.tex
			
#			sed -e "s/\end{document}/\begin{alltt}/g" Temp2-img2pdf-Spec.tex > Temp1-img2pdf-Spec.tex
#			echo " " >> Temp1-img2pdf-Spec.tex
#			tail -n+14 ../../Matlab/Log > Log2
#			sed -i '' -e '$ d' Log2
#			head -n 22 Log2 >> Temp1-img2pdf-Spec.tex
#			echo " " >> Temp1-img2pdf-Spec.tex
#			echo "\end{alltt}" >> Temp1-img2pdf-Spec.tex
#			echo "\end{document}" >> Temp1-img2pdf-Spec.tex
			
			pdflatex -shell-escape Temp2-img2pdf-Spec.tex
			mv Temp2-img2pdf-Spec.pdf ../../Matlab/Images/Sortie/2pdf/"$meth"_Schem"$iter"_Alpha"$alpha.pdf"
			rm Temp*-img2pdf-Spec.*
		done             
			cd ../../Matlab/
		
	done
	
	done

#done

rm TempMain1.m TempMain2.m