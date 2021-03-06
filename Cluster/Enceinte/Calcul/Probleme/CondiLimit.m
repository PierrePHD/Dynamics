function [D,conditionU,conditionV,conditionA,M,C,K0,HistF,U0,V0,verif] = CondiLimit(CL,M,C,K0,L,nombreElements,cas,dt,Ttot)

nombrePasTemps=round(Ttot/dt);

%% Encastrement en debut et fin (ressort encastre)
if (CL==1)
    % Expression generale
    % [D]*[a] = [ba]
    % [D]*[v] = [bv]
    % [D]*[u] = [bu]
    % Dependant du schema de resolution on imposera acceleration ou vitesse
    % les autres termes peuvent etre utilise comme correcteurs
    conditionA=zeros(1,nombrePasTemps+1);
    conditionV=zeros(1,nombrePasTemps+1);
    conditionU=zeros(1,nombrePasTemps+1);

    D = zeros(1,size(M,1));
    noeudAuDepImp= 1;
    D(1,noeudAuDepImp)=1;

    conditionA(1,:) = 0;    % [ba](1)
    conditionV(1,:) = 0;    % [bv](1)
    conditionU(1,:) = 0;    % [bu](1)

    noeudAuDepImp= size(M,1);
    D(2,noeudAuDepImp)=1;

    conditionA(2,:) = 0;    % [ba](2)
    conditionV(2,:) = 0;    % ....
    conditionU(2,:) = 0;         
elseif (CL==2)  % elemination     
    M=M(2:end-1,2:end-1);
    K0=K0(2:end-1,2:end-1);
    C=C(2:end-1,2:end-1);
end

%% Condition en effort
HistF=zeros(size(M,1),(nombrePasTemps+1)); % Donnees

if (CL==1)    
    NoeudCharge = size(M,1)-1;
elseif (CL==2)    
    NoeudCharge = size(M,1);
end

NbPas = 0;

if (cas.type == 2)
    omega = 2*pi/cas.T ; 
    HistF(NoeudCharge,:) = (1- cos( (0:dt:Ttot)*omega))*cas.AmpliF;
elseif (cas.type ==4)
    HistF(NoeudCharge,:) = cas.AmpliF;
elseif (cas.type ==5)
    HistF(NoeudCharge,:) = (0:dt:Ttot)*cas.AmpliF;
elseif (cas.type ==6)
    NbPas = round(cas.T/dt);
    HistF(NoeudCharge,1:NbPas) = cas.AmpliF;
elseif (cas.type ==8)
    omega=2*pi/cas.T;
    NbPas = round(cas.T/dt)+1;
    HistF(NoeudCharge,1:NbPas) = (1- cos( ((1:NbPas)*dt)*omega))*cas.AmpliF;
elseif (cas.type ==10.01)
    omega=2*pi/cas.T;
    
    NbPas = round((cas.T/dt)/2)+1;
    HistF(2,1:NbPas) = (sin( ((1:NbPas)*dt)*omega))*0.5*cas.AmpliF;
    HistF(2,(NbPas+1):end) = (((((NbPas+1):nombrePasTemps+1)*dt)-5)/10)*cas.AmpliF;
    
    HistF(3,:) = 0.2*cas.AmpliF;
elseif (cas.type ==10.02)
    omega=2*pi/cas.T;
    
    HistF(3,:) = (sin(omega*(0:dt:Ttot))).*(sin(7*omega*(0:dt:Ttot)))*cas.AmpliF;
elseif (cas.type ==10.1 || cas.type ==10.2)
    omega0=2*pi/cas.T;
    omega = 1.5*omega0 ; 
    NoeudCharge = 2;
    HistF(NoeudCharge,:) = (sin( (0:dt:Ttot)*omega))*cas.AmpliF;
    omega = 0.8*omega0 ; 
    NoeudCharge = 3;
    HistF(NoeudCharge,:) = (sin( (0:dt:Ttot)*omega))*cas.AmpliF;
end

if (NbPas > nombrePasTemps); Erreur; end;

NbOscil=Ttot/cas.T;
disp(['Le snapshot de ' num2str(Ttot, '%10.1e\n') 's permet '  num2str(NbOscil, '%10.1e\n') ' oscilations du chargement']);

%% Position et Vitesse initiales   
U0 = zeros(size(M,1),1);
V0 = zeros(size(M,1),1) ; 
if (cas.type==1)          % Deformee correspondant a un effort en bout
    if (CL==1)
        for j=1:(size(M,1)-1)     
            U0(j,1) = 0.1*L*(j-1)/nombreElements;
        end 
    elseif (CL==2)
        for j=1:size(M,1)       
            U0(j,1) = 0.1*L*j/nombreElements;
        end      
    end
elseif (cas.type==7)          % Vitesse initiale
    if (CL==1)
        for j=1:(size(M,1)-1)       
            V0(j,1) = 0.1*(L/dt)*(1/100)*(j-1)/nombreElements;
        end 
    elseif (CL==2)
        for j=1:size(M,1)       
            V0(j,1) = 0.1*(L/dt)*(1/100)*j/nombreElements;
        end      
    end
end

%% Deplacement impose au cours du temps
if (cas.type ==3)
    omega=2*pi/cas.T;
    noeudAuDepImp= ceil(size(M,1)/2);
    if (CL==1)
        NumeroCondition = 3;
    elseif (CL==2)
        D = zeros(1,size(M,1));
        NumeroCondition = 1;
    end        
        D(NumeroCondition,noeudAuDepImp)=1;
        conditionA(NumeroCondition,:) = -omega^2 * cos( (0:dt:Ttot)*omega) /100;    
        conditionV(NumeroCondition,:) = -omega   * sin( (0:dt:Ttot)*omega) /100; 
        conditionU(NumeroCondition,:) = (-1      + cos( (0:dt:Ttot)*omega))/100;
elseif (cas.type ==10)
%     omega=2*pi/cas.T;
%     noeudAuDepImp= size(M,1);
%     if (CL==1)
%         NumeroCondition = 2;
%     elseif (CL==2)
%         D = zeros(1,size(M,1));
%         NumeroCondition = 1;
%     end        
%         D(NumeroCondition,noeudAuDepImp)=1;
%         conditionA(NumeroCondition,:) = -omega^2 * cos( (0:dt:Ttot)*omega) /100;    
%         conditionV(NumeroCondition,:) = -omega   * sin( (0:dt:Ttot)*omega) /100; 
%         conditionU(NumeroCondition,:) = (-1      + cos( (0:dt:Ttot)*omega))/100;
elseif (CL==2)    
        D = [];
        conditionA = [];   
        conditionV = []; 
        conditionU = [];
end


    verif=0;
    if (size(D,1))      % correction de l erreur d integration, impossible si les deplacements sont lies
     verif=1;           % verification que les deplacement ne sont pas lies
     
     % Y a t il deux elements non nul sur la meme ligne de D : deplacements lies
     [c,~]=find(D);
     for j=1:size(c,1)
        for k=1:size(c,1)
             if k~=j 
                 if ( c(j)==c(k) || verif == 0)
                     verif = 0;
                     DeplacementsLies;
                     break;
                 end
             end
        end
     end
     
     % Y a t il deux elements non nul sur la meme colonne de D : double definition
     [~,c]=find(D);
     for j=1:size(c,1)
        for k=1:size(c,1)
             if k~=j 
                 if ( c(j)==c(k) || verif == 0)
                     verif = 0;
                     DoubleDefinition;
                     break;
                 end
             end
        end
     end     
     
     % Les colonnes sont elles normees
     [c,d]=find(D);
     for j=1:size(c,1)
         if ( D(c(j),d(j))~=1 || verif == 0)
             verif = 0;
             ColonnesNonNomee;
             break;
        end
     end
     
     
    end    
    







