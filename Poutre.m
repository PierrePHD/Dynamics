function [problem] = Poutre(calcul)

    % Poutre
        L = 0.5;            % 0.5 m^2
        Egene = (210*10^9); % 210 GPa
        ENonConstant=0;
        ecart = 0.5;        % max( (Egene-E)/Egene )
        Sec=10^(-4);        % 10^-4 m^2 = 1 cm^2
        rho=7.8*10^3;       % kg/m^3

    % Ressort
        % Lres = L/8;
        % kres = Egene*Sec/Lres;
        Lres = 0;
        kres = 0;
        nonLine = 0; %1;
        
    if (calcul.CL==1)
        VectL=[0:L/calcul.nombreElements:L L+Lres];
    elseif (calcul.CL==2)
        VectL=L/calcul.nombreElements:L/calcul.nombreElements:L;
    end

    % temps
        Ttot= 1.0e-03;% * 5^program;% calcul.dt*400; %3.0000e-04;

        %c=(Egene/rho)^(0.5);
        %NbOscil=Ttot/(2*L/c);          % correct si E constant / recalcule plus loin
        nombrePasTemps=round(Ttot/calcul.dt); % Attention doit etre entier car ceil pose des problemes
        %VectT=0:calcul.dt:Ttot;

    % Solicitaion :
        disp(['cas = ' num2str(calcul.cas.type)]);
        % 1 Deformee de depart correspondant a un effort en bout de poutre puis relachee
        % 2 Effort sinusoidal en bout de poutre
        % 3 Deplacement impose en milieu de poutre
        % 4 Effort continue en bout de poutre
        % 5 Effort augmentant lineairement en bout de poutre
        % 6 Effort continue en bout de poutre les premiers pas de temps
            %cas.T = 2e-4;
        % 7 Vitesse initiale
        % 8 Une periode de sinusverse
            %cas.T = 100*calcul.dt*2;%^iterCase; % 10*calcul.dt < T < Ttot/4  
            
            %fileID = fopen('PGD.Conv.dat','a');
            %fprintf(fileID,' \t');
            %fclose(fileID);

    % Matrice de Masse :
        RepartMasse = 3;
        % 1 Me= [1/2  0 ;  0  1/2]  la masse est repartie equitablement entre les deux
        % 2 Me= [ 0   0 ;  0   1 ]  la masse est donnee au noeud a la droite de l'element
        % 3 Me= [1/3 1/6; 1/6 1/3]  la masse est repartie comme le decrivent les fonctions EF
    
    nombreNoeuds = calcul.nombreElements + 2;  % avec le noeud derriere le ressort
    LElement = L/calcul.nombreElements;

    [nonLinearite,M,K0,C] = ConstructionMatrices(calcul.nombreElements,nombreNoeuds,LElement,Sec,rho,Egene,ENonConstant,Ttot,RepartMasse,nonLine);

    [D,conditionU,conditionV,conditionA,M,C,K0,HistF,U0,V0,verif] = CondiLimit(calcul.CL,M,C,K0,L,calcul.nombreElements,calcul.cas,nombrePasTemps,calcul.dt,Ttot);
      
    
    problem.Egene = Egene ;
    problem.Sec = Sec ;
    problem.L = L ;
    problem.rho = rho ;
    problem.kres = kres ;
    problem.ENonConstant = ENonConstant;
    
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