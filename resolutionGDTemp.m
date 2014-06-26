function [sortie] = resolutionGDTemp(M,C,K0,dt,Ttot,HistF,U0,V0,conditionU,conditionV,conditionA,D,nonLine,nonLinearite,verif)
%% Initialisation

    HistU_m=zeros(size(HistF));
    HistU_p=zeros(size(HistF));
    HistV_m=zeros(size(HistF));
    HistV_p=zeros(size(HistF));
    % HistA=zeros(size(HistF));
    % HistE  =zeros(1,size(HistF,2));
    % HistEc =zeros(1,size(HistF,2));
    % HistEp =zeros(1,size(HistF,2));
    % HistEnl=zeros(1,size(HistF,2));
    % HistEf =zeros(1,size(HistF,2));
    % Ef =0;
    % HistEu =zeros(1,size(HistF,2));
    % Eu =0;
    
    K = K0;
    
%% Conditions Initiales
    
    if norm(U0)
        if (verif)
            [i,~]=find(D');
            U0(i,1) = conditionU(:,1);
        elseif (norm(D) == 0)            
        else
            ErreurVerifConditionInitialNonPriseEnCompte;
        end     
    end
    U_m = U0;   % deplacements - vecteur colonne
    U_p = U0;
    V_m = V0;   % vitesses
    V_p = V0;
%     A = zeros(size(M,1),1);     % accelerations
    
    nombrePasTemps=round(Ttot/dt); % Attention doit etre entier car ceil pose des problemes
    
%     if (nonLine==1)
%         % Ajout du ressort
%         kres =  nonLinearite(1).scalaires(1);
%         KresU = nonLinearite(1).matriceKUnit;
%         UresU = nonLinearite(1).dependanceEnU;
%     end

    
%% Iterations Temporelles
    
    
    for t=0:nombrePasTemps
        
        if t==0            
            HistU_m(:,t+1)  = U_m;
            HistU_p(:,t+1)  = U_p;
            HistV_m(:,t+1)  = V_m;
            HistV_p(:,t+1)  = V_p;
        else       
            % % Gravouil 
               %  Mp= (1/2)*M + (5/36)*(dt^2)*K;
               %  F1 = dt*( (1/3)*HistF(:,t) + (1/6)*HistF(:,t+1) );
               %  F2 = dt*( (1/6)*HistF(:,t) + (1/3)*HistF(:,t+1) );
               %  F1p=        -(1/2)*dt*K*U_m + F2;
               %  F2p= M*V_m  -(1/2)*dt*K*U_m + F1;
               %  VmVp = [ -(1/2)*M+(7/36)*(dt^2)*K           Mp              ;
               %                      Mp              (1/2)*M+(1/36)*(dt^2)*K ] \ [F1p ; F2p]; % Mettre en place multiplicateur Lagrange
            % % Perso
                F1p= M*V_m + (1/2)*dt*(HistF(:,t) + HistF(:,t+1)) - dt*K*U_m;
                F2p= -(1/6)*dt*(K*U_m - HistF(:,t+1)) - (1/3)*M*V_m;
                
                
               if min(size(conditionV))==0
                   VmVp = [ (1/3)*(dt^2)*K+(1/2)*dt*C  (1/6)*(dt^2)*K+M+(1/2)*dt*C ; 
                           (1/12)*(dt^2)*K-(1/2)*M  (1/12)*(dt^2)*K+(1/6)*M+(1/6)*dt*C ] \ [F1p ; F2p]; 
               else                           
                   VmVp = [ (1/3)*(dt^2)*K+(1/2)*dt*C  (1/6)*(dt^2)*K+M+(1/2)*dt*C          D'              zeros(size(D')); 
                            (1/12)*(dt^2)*K-(1/2)*M   (1/12)*(dt^2)*K+(1/6)*M+(1/6)*dt*C  zeros(size(D'))        D';
                                      D                              zeros(size(D))       zeros(size(D,1))  zeros(size(D,1));
                                      zeros(size(D))                      D               zeros(size(D,1))  zeros(size(D,1))  ] \ [F1p ; F2p ; conditionV(:,t) ; conditionV(:,t+1)];
               end
                
              %  if min(size(conditionV))==0
              %      VmVp = [ (11/6)*(dt^2)*K+(1/2)*dt*C  (4/3)*(dt^2)*K+M+(1/2)*dt*C ; 
              %                (1/3)*(dt^2)*K-(1/2)*M     -(1/6)*(dt^2)*K+(1/6)*M+(1/6)*dt*C ] \ [F1p ; F2p]; 
              %  else                           
              %      VmVp = [ (11/6)*(dt^2)*K+(1/2)*dt*C  (4/3)*(dt^2)*K+M+(1/2)*dt*C         D'              zeros(size(D')); 
              %                (1/3)*(dt^2)*K-(1/2)*M    -(1/6)*(dt^2)*K+(1/6)*M+(1/6)*dt*C  zeros(size(D'))        D';
              %                         D                              zeros(size(D))       zeros(size(D,1))  zeros(size(D,1));
              %                         zeros(size(D))                      D               zeros(size(D,1))  zeros(size(D,1))  ] \ [F1p ; F2p ; conditionV(:,t) ; conditionV(:,t+1)];
              %  end
                
            V_m = VmVp((size(V_m)+1):(size(V_m)*2));  %V_m(t+1)
            V_p = VmVp(1:size(V_m));        %V_p(t)
            
            U_p = U_m + (1/6)*dt*V_p - (1/6)*dt*V_m; %U_p(t)
            U_m = U_m + (1/2)*dt*V_p + (1/2)*dt*V_m; %U_m(t+1)

            % U_p = U_m + (10/6)*dt*V_p - (10/6)*dt*V_m; %U_p(t)
            % U_m = U_m + 2*dt*V_p  - 1*dt*V_m; %U_m(t+1)            
            
            HistU_m(:,t+1)  = U_m;
            HistU_p(:,t  )  = U_p;
            HistV_m(:,t+1)  = V_m;
            HistV_p(:,t  )  = V_p;
            
%             if mod(t,round(nombrePasTemps/100)) == 0
%                 fait = round(100*t/nombrePasTemps);
%                 disp(['fait = ' num2str(fait) '%']);
%             end
        end
    
    end
        
    sortie.HistU_m= HistU_m;
    sortie.HistU_p= HistU_p;
    sortie.HistV_m= HistV_m;
    sortie.HistV_p= HistV_p;
    
    for i=1:size(HistU_m,2)
        sortie.HistU_plot(:,(i-1)*3+1)=HistU_m(:,i);
        sortie.HistU_plot(:,(i-1)*3+2)=HistU_m(:,i)*NaN;
        sortie.HistU_plot(:,(i-1)*3+3)=HistU_p(:,i);
    end
    for i=1:size(0:dt:Ttot,2)
        sortie.VectTplotGD((i-1)*3+1)=(i-1)*dt;
        sortie.VectTplotGD((i-1)*3+2)=(i-1)*dt;
        sortie.VectTplotGD((i-1)*3+3)=(i-1)*dt;
    end
    
%     surf(SoluComplete.f.VectTplotGD,problem.VectL,SoluComplete.f.HistU_plot,'EdgeColor','none');
%     plot(SoluComplete.f.VectTplotGD,SoluComplete.f.HistU_plot(40,:),SoluComplete.f.VectTplotGD,SoluComplete.f.HistU_plot(end-1,:),'r',0:calcul.dt:problem.Ttot,(problem.HistF(end-1,:)/(2*cas.AmpliF))*max(SoluComplete.f.HistU(end-1,:)),'LineWidth',2);
    
    sortie.HistU= zeros(size(HistU_m));
    sortie.HistU(:,1)= HistU_p(:,1);
    sortie.HistU(:,2:end-1)= (HistU_p(:,2:end-1)+HistU_m(:,2:end-1))/2;
    sortie.HistU(:,end)= HistU_m(:,end);
    
	sortie.HistV= zeros(size(HistV_m));
    sortie.HistV(:,1)= HistV_p(:,1);
    sortie.HistV(:,2:end-1)= (HistV_p(:,2:end-1)+HistV_m(:,2:end-1))/2;
    sortie.HistV(:,end)= HistV_m(:,end);
    
    

    
    
    
    