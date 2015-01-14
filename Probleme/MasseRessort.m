function [problem] = MasseRessort(calcul)

    if (calcul.cas.type == 10.2)
        nonLine = 1;
    else
        nonLine = 0;
    end

    nombreElements = 3;

    m = zeros(1,nombreElements+1);
    VectL = zeros(1,nombreElements+1);

    k = zeros(1,nombreElements);
    L = zeros(1,nombreElements);
    c = zeros(1,nombreElements);
    
    if ((calcul.cas.type -10) <0.1)

        m(2:3) = 1;     % Masse Kg

        L(1:2) = 1;       % Longueur m
        k(1:2) = 1;      % Raideur N/m
        c(1:2) = 0.7;       % Viscosite N.s/m

    else

        %   Equivalence avec le modele poutre adapte
        %     m(2:3) = 10^(-4) * 0.25 * 7.8*10^3 ;     % Masse Kg
        % 
        %     L(1:3) = 0.25;       % Longueur m
        %     k(1:3) = 210*10^9 * 10^(-4) / L(1);      % Raideur N/m
        %     c(1:3) = k(1)*0.000001;       % Viscosite N.s/m

        m(2:3)=1;
        k(1:3)=1000;
        c(1:3)= 2 * 0.7 * sqrt(k(1)*m(2));
        L(1:3)= 1;
    end
    
    
    K0 = zeros(4);
    C  = zeros(4);
    
    nonLinearite(1)=struct('scalaires',[],'matriceKUnit',[],'dependanceEnU',[]);
    if (nonLine==1)
        % Ajout du ressort non lineaire
        k(3)=0;
        nonLinearite(1).matriceKUnit = zeros(size(K0,1));
        nonLinearite(1).dependanceEnU = zeros(size(K0,1),1);
        nonLinearite(1).dependanceEnU((end-1):end,1) = [1 -1];
        nonLinearite(1).matriceKUnit((end-1):end,(end-1):end) = [1 -1;-1 1];
        kres        = 1000 ;
        VarSoupl    = 1000 ;
        VarJeu      = 0.3e-2 ;
        nonLinearite(1).scalaires(1) = kres;
        %nonLinearite(1).fonction = @(x,y) (kres)*(exp(VarSoupl*(x'*y-VarJeu))-1)+kres;
        DeltaJ = 1e-4;
        nonLinearite(1).fonction = @(x,y) ButeeParPartie(VarJeu,DeltaJ,kres,x,y);
        
        
%         k(1)=0;
%         nonLinearite(2).matriceKUnit = zeros(size(K0,1));
%         nonLinearite(2).dependanceEnU = zeros(size(K0,1),1);
%         nonLinearite(2).dependanceEnU(1:2,1) = [1 -1];
%         nonLinearite(2).matriceKUnit(1:2,1:2) = [1 -1;-1 1];
%         kres        = 1000 ;
%         VarSoupl    = 1000 ;
%         VarJeu      = 1e-3 ;
%         nonLinearite(2).scalaires(1) = kres;
%         nonLinearite(2).fonction = @(x,y) (kres*VarSoupl)*(exp(VarSoupl*(x'*y-VarJeu))-1)+kres;  
    end
    
    
    for i=1:nombreElements
        KElem = [k(i) -k(i);-k(i) k(i)];
        K0(i:i+1,i:i+1) = K0(i:i+1,i:i+1)+KElem;
        CElem = [c(i) -c(i);-c(i) c(i)];
        C(i:i+1,i:i+1) = C(i:i+1,i:i+1)+CElem;
        VectL(i+1) = VectL(i) + L(i);
    end
    
    M = diag(m);
    
    NbOscil=calcul.Ttot*   ((sqrt(k(1)/m(2)))/(2*pi));
    disp(['Le snapshot de ' num2str(calcul.Ttot, '%10.1e\n') 's permet '  num2str(NbOscil, '%10.1e\n') ' oscilations']);
    
    
    
    [D,conditionU,conditionV,conditionA,M,C,K0,HistF,U0,V0,verif] = CondiLimit(calcul.CL,M,C,K0,VectL(end),nombreElements,calcul.cas,calcul.dt,calcul.Ttot);
    
    problem.M = M ;
    problem.C = C ;
    problem.K0 = K0 ;
%    problem.kres = kres ;
    
    problem.Ttot = calcul.Ttot ;
    problem.VectL = VectL ;
    problem.D = D ;
    problem.conditionU = conditionU ;
    problem.conditionV = conditionV ;
    problem.conditionA = conditionA ;
    problem.HistF = HistF ;
    problem.U0 = U0 ;
    problem.V0 = V0 ;
    problem.nonLine = nonLine ;
    problem.nonLinearite = nonLinearite ;
    problem.verif = verif ;
    problem.calcul = calcul ;
    
end
 