#!/bin/sh
    
cd /Users/pierrephd/Dropbox/Travail/Git/PierrePHD/Dynamics/Matlab   

for meth in POD PGD                                              
do
	sed -e "s/ErrPOD = AfficherMethode(Ref,SoluPOD,MET,ME,MT,Res,NDR,NDE,OI);/Err$meth = AfficherMethode(Ref,Solu$meth,MET,ME,MT,Res,NDR,NDE,OI);/g" main.m > TempMain1.m
	
	echo "_______*****_______" >> LogTerm
	echo $meth >> LogTerm
	echo "_______*****_______" >> LogTerm

	for iter in `seq 3 6` #6480`
	do
		
		echo "__**__" >> LogTerm
		echo $iter >> LogTerm
		echo "__**__" >> LogTerm
		
		sed -e "s/calcul = ParamCalcul(4e-6   ,3,-1\/3 );/calcul = ParamCalcul(4e-6   ,$iter,-1\/3 );/g" TempMain1.m > TempMain2.m
		
		/Applications/MATLAB_R2012a.app/bin/matlab -nodesktop -nodisplay -r TempMain2
		
		cd ../Latex/Auto/
		#cd Images/Sortie/2pdf/
		pdflatex -shell-escape img2pdf-Spec.tex
		mv img2pdf-Spec.pdf ../Matlab/Images/Sortie/PremiersModes/SansOrtho/"Schem$iter/$meth.pdf"
		cd ../../Matlab/
		
	done

done

rm TempMain1.m TempMain2.m