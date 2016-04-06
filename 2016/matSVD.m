function [] = matSVD(NbMod,Nb_Comp,Nb_Noeu)


% NbMod = 2  ;    % Rentrer en parametre
% Nb_Comp = 3 ;   %
% Nb_Noeu = 22 ;  %

bb = csvread('FileOUT.csv',1,0);
[mat,padded] = vec2mat(bb,(Nb_Noeu*Nb_Comp)); % ici 22 pour X Y et Z, et que faire des rotations ? !!!!

if padded==0
    [U,S,V] = svd(mat');
else
    ErrorMaivaiseTaille
end
ValS = diag(S);

for i=1:NbMod
    for j=1:Nb_Comp
        Prem_ind = 1 + (j-1)*Nb_Noeu ;
        Dern_ind = (Prem_ind + Nb_Noeu) - 1 ;
        csvwrite(['FileMatlab_' sprintf('%03d',i) '_Comp_' sprintf('%03d',j)], U(Prem_ind:Dern_ind,i)) ;
    end
end

csvwrite('FileMatValS', ValS(1:NbMod)) ;

exit;
