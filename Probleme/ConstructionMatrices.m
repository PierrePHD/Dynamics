function [nonLinearite,M,K0,C] = ConstructionMatrices(nombreElements,nombreNoeuds,LElement,Sec,rho,Egene,ENonConstant,Ttot,RepartMasse,nonLine,kres)

% M.A + C.V + K.U = F

M  = zeros(nombreNoeuds);        % masse
K0 = zeros(nombreNoeuds);       % raideur - Sans les elements non-lineaires
%C  = zeros(nombreNoeuds);              % Amortissement Test

TempPropa=0;

for i=1:nombreElements
    
    if (RepartMasse == 1)          %[1/2 0; 0 1/2]
        M(i:(i+1),i:(i+1)) = M(i:(i+1),i:(i+1)) + [1/2  0 ;  0  1/2]*Sec*LElement*rho;
        % l'element k est compris entre le noeud k et le noeud k+1
        % la masse est repartie equitablement entre les deux
    elseif (RepartMasse == 2)      %[0 0; 0 1]
        M(i:(i+1),i:(i+1)) = M(i:(i+1),i:(i+1)) + [ 0   0 ;  0   1 ]*Sec*LElement*rho;
        % la masse est donnee au noeud a la droite de l'element
    elseif (RepartMasse == 3)
        M(i:(i+1),i:(i+1)) = M(i:(i+1),i:(i+1)) + [1/3 1/6; 1/6 1/3]*Sec*LElement*rho;
        % la masse est repartie comme le decrivent les fonctions EF
    end
    
        
    if (ENonConstant==1)
        Elocal = Egene*(1+ecart*(   -(  (ceil(i/nombreElementsParPartie)*2)/nombrePartie) +1));  % evolution lineaire par partie de la poutre
        k = Elocal*Sec/LElement;
        c=(Elocal/rho)^(0.5);
    else
        k = Egene*Sec/LElement;     % ici on pourra choisir un E qui change en fonction des elements
        c=(Egene/rho)^(0.5);
    end
    
    TempPropa=TempPropa + LElement/c;
    KElem = [k -k;-k k];
    K0(i:i+1,i:i+1) = K0(i:i+1,i:i+1)+KElem;
    
end

if nonLine==0
    KElem = [kres -kres;-kres kres];
    K0((end-1):end,(end-1):end) = K0((end-1):end,(end-1):end)+KElem;
end

C = K0*0.001;

NbOscil=Ttot/(2*TempPropa);
disp(['Le snapshot de ' num2str(Ttot, '%10.1e\n') 's permet '  num2str(NbOscil, '%10.1e\n') ' propagations']);

nonLinearite(1)=struct('scalaires',[],'matriceKUnit',[],'dependanceEnU',[]);
if (nonLine==1)
    % Ajout du ressort
    nonLinearite(1).matriceKUnit = zeros(size(K0,1));
    nonLinearite(1).dependanceEnU = zeros(size(M,1),1);
    nonLinearite(1).dependanceEnU((end-1):end,1) = [1 -1];
    nonLinearite(1).matriceKUnit((end-1):end,(end-1):end) = [1 -1;-1 1];
    nonLinearite(1).scalaires(1) = kres;
    %nonLinearite(1).fonction = @(x,y) kres*(abs((x'*y)))^0.5;
    VarSoupl    = 1000 ;
    VarJeu      = 1e-7 ;
    nonLinearite(1).fonction = @(x,y) (kres*VarSoupl)*(exp(VarSoupl*(x'*y-VarJeu))-1)+kres;   
    %nonLinearite(1).fonction = @(x,y) (kres/VarSoupl)*(exp(VarSoupl*(x'*y-VarJeu))-1)+kres*(x'*y);   
        %     VarSoupl    = 10 ;
        %     VarJeu      = 0.8 ;
        %     kres = 1 ;
        %     f =@(x) ((kres/VarSoupl)*(exp(VarSoupl*(x-VarJeu))-1)+kres*VarJeu);
        %     plot(0:0.01:1,f(0:0.01:1));
        
        %     J      = 0.7;
        %     dJ = 0.1;
        %     kres = 1 ;
        %     nonLinearite(1).fonction = @(x,y) ((kres*dJ^2)/(((x'*y)-J)-dJ) + kres*(J-dJ)); 
end

end