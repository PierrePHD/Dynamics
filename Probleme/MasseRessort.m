function [problem] = MasseRessort(calcul)


    nonLine = 0;
    nonLinearite(1)=struct('scalaires',[],'matriceKUnit',[],'dependanceEnU',[]);

    nombreElements = 3;

    m = zeros(1,nombreElements+1);
    VectL = zeros(1,nombreElements+1);

    k = zeros(1,nombreElements);
    L = zeros(1,nombreElements);
    c = zeros(1,nombreElements);
    
    if (calcul.cas.type == 9)

        m(2) = 1;     % Masse Kg
        m(3) = 1;

        L(1:2) = 1;       % Longueur m
        k(1:2) = 1;      % Raideur N/m
        c(1:2) = 0.0001;       % Viscosite N.s/m

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
    
    for i=1:nombreElements
        KElem = [k(i) -k(i);-k(i) k(i)];
        K0(i:i+1,i:i+1) = K0(i:i+1,i:i+1)+KElem;
        CElem = [c(i) -c(i);-c(i) c(i)];
        C(i:i+1,i:i+1) = C(i:i+1,i:i+1)+CElem;
        VectL(i+1) = VectL(i) + L(i);
    end
    
    M = diag(m);
    
    Ttot= 1.0e-03;% * 5^program;% calcul.dt*400; %3.0000e-04;
    
    NbOscil=Ttot/(2*(sqrt(k(1)/m(2))));
    disp(['Le snapshot de ' num2str(Ttot, '%10.1e\n') 's permet '  num2str(NbOscil, '%10.1e\n') ' oscilations']);
    
    [D,conditionU,conditionV,conditionA,M,C,K0,HistF,U0,V0,verif] = CondiLimit(calcul.CL,M,C,K0,0.5,nombreElements,calcul.cas,calcul.dt,Ttot);
    
    problem.M = M ;
    problem.C = C ;
    problem.K0 = K0 ;
    
    problem.Ttot = Ttot ;
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
 