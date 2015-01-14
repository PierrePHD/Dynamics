#!/bin/sh
    
cd /Users/pierrephd/Dropbox/Travail/Git/PierrePHD/Dynamics/Matlab   


	#sed -e "s/ErrPOD = AfficherMethode(Ref,SoluPOD,MET,ME,MT,Res,NDR,NDE,OI);/Err$meth = AfficherMethode(Ref,Solu$meth,MET,ME,MT,Res,NDR,NDE,OI);/g" main.m > TempMain1.m
	
	sed -e "s/%exit/exit/g" ModesCroises.m > TempMain1.m
	#sed -e "s/FR$meth = 0 ;/FR$meth = 1 ;/g" TempMain1.m > TempMain2.m

	for iter in `seq 3 6` 
	do
		
		sed -E "s/OutCas8schem[3-6].mat/OutCas8schem$iter.mat/g" TempMain1.m > TempMain2.m
		
		sudo /Applications/MATLAB_R2012a.app/bin/matlab -nodesktop -nodisplay -r TempMain2 
		mv Images/Sortie/MAC_POD-PGD.png "MAC_POD-PGD-schem$iter.png"
		
	done


rm TempMain1.m TempMain2.m