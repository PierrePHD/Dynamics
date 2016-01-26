#!/bin/bash

head -n 4 Procedures/ProblemVide > Procedures/Temp/CreationProb_PR.dgibi
cat $2 >> Procedures/Temp/CreationProb_PR.dgibi
tail -n 5 Procedures/ProblemVide >> Procedures/Temp/CreationProb_PR.dgibi

printf "" > ConcatTemp

for FichierProc in Procedures/*/*_PR.dgibi
do
	printf '$$$$ ' >> ConcatTemp
	# Castem Compatible
	cat $FichierProc | tr -d "\t" | sed -E '/^ *$/d' | sed -e 's/^[ 	]*//' > Temp1
		#Retirer les tabulations, les lignes vides
	sed \1d Temp1 >> ConcatTemp
done

cp $1 TempMain
for FichierProc in Procedures/*/*_PR.dgibi
do
	NomCastem=`head -n 1 "$FichierProc"`
	NomClair=`sed \1d "$FichierProc" | head -n 1`
	sed "s/$NomClair/$NomCastem/g" ConcatTemp > Temp1
	sed "s/$NomClair/$NomCastem/g" TempMain > Temp2
	cat Temp1 > ConcatTemp
	cat Temp2 > TempMain
done

cat listeDesVariables | tr -d "\t" | sed -E '/^ *$/d'  > TempVariables

while read NomClair
do
	read NomCastem
	sed "s/$NomClair/$NomCastem/g" ConcatTemp > Temp2
	sed "s/$NomClair/$NomCastem/g" TempMain > Temp3
	cat Temp2 > ConcatTemp
	cat Temp3 > TempMain
done < TempVariables


printf '$$$$' >> ConcatTemp


cat ConcatTemp | tr -d "\t" | sed -E '/^ *$/d' > ConcatProc.dgibi
	MAX=0
	while read -r line; do
	  if [ ${#line} -gt $MAX ]; then MAX=${#line}; fi
	done < ConcatProc.dgibi
	if [ $MAX -gt 72 ]; then echo "depassement de 72 caracteres dans ConcatProc.dgibi"; sleep 10; fi

cat TempMain | tr -d "\t" | sed -E '/^ *$/d' | sed 's/^ *//' > $1.dgibi
	MAX=0
	while read -r line; do
	  if [ ${#line} -gt $MAX ]; then MAX=${#line}; fi
	done < $1.dgibi
	if [ $MAX -gt 72 ]; then echo "depassement de 72 caracteres dans $1.dgibi"; sleep 10; fi

rm Temp1 Temp2 Temp3 ConcatTemp TempMain

echo "Procedures"
castem14 ScriptUtil.dgibi > /dev/null

echo ""
echo "Main"
castem14 $1.dgibi

echo "Fin Script"
