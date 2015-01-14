close all
clear all
load('VarMassR.mat')
load('VarPoutre.mat')
load('prob.mat')
AfficherSolution(UMassR,UPoutre,'Compare',0:problem.calcul.dt:problem.Ttot,problem.VectL,0);



UPoutre = SoluComplete.f.HistU;
save('VarPoutre','UPoutre')

UMassR = SoluComplete.f.HistU;
save('VarMassR','UMassR')

