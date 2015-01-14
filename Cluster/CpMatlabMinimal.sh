#!/bin/sh

mkdir -p MatlabLocal/Images/Sortie
mkdir MatlabLocal/Afficher
mkdir MatlabLocal/Probleme
mkdir MatlabLocal/POD
mkdir MatlabLocal/PGD

for file in main.m Resolution.m resolutionTemporelle.m ParamCalcul.m
do
	cp "../../Matlab/$file" MatlabLocal/
done

for file in AfficherMethode.m AfficherSolution.m
do
	cp "../../Matlab/Afficher/$file" MatlabLocal/Afficher/
done

for file in CondiLimit.m ConstructionMatrices.m Poutre.m
do
	cp "../../Matlab/Probleme/$file" MatlabLocal/Probleme/
done

for file in BaseReduite.m Projection.m
do
	cp "../../Matlab/POD/$file" MatlabLocal/POD/
done

for file in CalcModesPGD.m ProblemEspace.m PointFixePGD.m ProblemTemps.m IntegrLine.m
do
	cp "../../Matlab/PGD/$file" MatlabLocal/PGD/
done

