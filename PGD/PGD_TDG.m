function [g] = PGD_TDG(problem, f_q, m, dt, HistMf, HistMg)
%% Iterations Temporelles
    
    SizeVectT = size(problem.HistF,2);
    

    Hist_g_U_m=zeros(SizeVectT,1);
    Hist_g_U_p=zeros(SizeVectT,1);
    Hist_g_V_m=zeros(SizeVectT,1);
    Hist_g_V_p=zeros(SizeVectT,1);
    Hist_g_W  =zeros(SizeVectT,1);
    
    pKp=f_q'*problem.K0*f_q;
    pMp=f_q'*problem.M*f_q;
    pCp=f_q'*problem.C*f_q;
    
    pHistF = f_q'*problem.HistF;
    
    g_U_m=0;
    g_V_m=0;
    
    pKp_i=zeros(1,m-1);
    pMp_i=zeros(1,m-1);
    pCp_i=zeros(1,m-1);
    
    % En cas de nonlinearite, recalcul necessaire des matrices
    for i=1:(m-1)
        pKp_i(i)=f_q'*problem.K0*HistMf(:,i);
        pCp_i(i)=f_q'*problem.C*HistMf(:,i);
        pMp_i(i)=f_q'*problem.M*HistMf(:,i);
    end
    
    
    for t=1:(SizeVectT-1)
        SM_ig_i=0;
        SK_ig_i=0;
        for i=1:(m-1)
            SM_ig_i=SM_ig_i+ pMp_i(i)*HistMg(i).v.m(t);
            SK_ig_i=SK_ig_i+ pKp_i(i)*HistMg(i).u.m(t);
        end

        F1p= pMp*g_V_m + SM_ig_i + (1/2)*dt*(pHistF(:,t) + pHistF(:,t+1)) - dt*(pKp*g_U_m + SK_ig_i);
        F2p= -(1/6)*dt*((pKp*g_U_m + SK_ig_i) - pHistF(:,t+1)) - (1/3)*(pMp*g_V_m + SM_ig_i);

        for i=1:(m-1)
            S11 = (1/3)*(dt^2)*pKp_i(i)+(1/2)*dt*pCp_i(i) ;
            S12 = (1/6)*(dt^2)*pKp_i(i)+pMp_i(i)+(1/2)*dt*pCp_i(i) ;
            S21 = (1/12)*(dt^2)*pKp_i(i)-(1/2)*pMp_i(i) ;
            S22 = (1/12)*(dt^2)*pKp_i(i)+(1/6)*pMp_i(i)+(1/6)*dt*pCp_i(i) ;

            Sum = [ S11 S12;
                     S21 S22] * [HistMg(i).v.p(t) ; HistMg(i).v.m(t+1)];

            F1p= F1p - Sum(1);
            F2p= F2p - Sum(2);
        end

        S11 = (1/3)*(dt^2)*pKp+(1/2)*dt*pCp ;
        S12 = (1/6)*(dt^2)*pKp+pMp+(1/2)*dt*pCp ;
        S21 = (1/12)*(dt^2)*pKp-(1/2)*pMp ;
        S22 = (1/12)*(dt^2)*pKp+(1/6)*pMp+(1/6)*dt*pCp ;

        VmVp = [ S11 S12;
                 S21 S22] \ [F1p ; F2p]; % Mettre en place multiplicateur Lagrange

        g_V_p = VmVp(1);  %V_p(t)
        g_V_m = VmVp(2);  %V_m(t+1)

        F1p= SK_ig_i;
        F2p= SK_ig_i;
        
        for i=1:(m-1)
            S11 = pKp_i(i) ;
            S13 = -(1/6)*dt*pKp_i(i) ;
            S14 =  (1/6)*dt*pKp_i(i) ;
            S22 = pKp_i(i) ;
            S23 = -(1/2)*dt*pKp_i(i) ;
            S24 = -(1/2)*dt*pKp_i(i) ;

            Sum = [ S11 0   S13 S14;
                    0   S22 S23 S24] * [HistMg(i).u.p(t) ; HistMg(i).u.m(t+1) ; HistMg(i).v.p(t) ; HistMg(i).v.m(t+1)];

            F1p= F1p - Sum(1);
            F2p= F2p - Sum(2);
        end
        
        g_U_p = ( (g_U_m + (1/6)*dt*g_V_p - (1/6)*dt*g_V_m)*pKp +F1p)/pKp; %U_p(t)
        g_U_m = ( (g_U_m + (1/2)*dt*g_V_p + (1/2)*dt*g_V_m)*pKp +F2p)/pKp; %U_m(t+1)   
              
        Hist_g_U_m(t+1)  = g_U_m;
        Hist_g_U_p(t  )  = g_U_p;
        Hist_g_V_m(t+1)  = g_V_m;
        Hist_g_V_p(t  )  = g_V_p;
        V1=( Hist_g_V_p(t  )+Hist_g_V_m(t  ) )/2;
        V2=( Hist_g_V_p(t+1)+Hist_g_V_m(t+1) )/2;
        if t==1
            V1=g_V_p;
        elseif t == (SizeVectT-1)
        	V2=g_V_m;
            Hist_g_W(t+1)   = (V1-V2)/dt;
        end
        
        Hist_g_W(t  )   = (V1-V2)/dt;

%         if mod(t,round(nombrePasTemps/100)) == 0
%             fait = round(100*t/nombrePasTemps);
%             disp(['fait = ' num2str(fait) '%']);
%         end

    end
    g.u.m=Hist_g_U_m;
    g.u.p=Hist_g_U_p;
    g.v.m=Hist_g_V_m;
    g.v.p=Hist_g_V_p;
    g.w  =Hist_g_W;
    
    for i=1:size(g.u.m,1)
        g.u.plot((i-1)*3+1)=g.u.m(i);
        g.u.plot((i-1)*3+2)=g.u.m(i)*NaN;
        g.u.plot((i-1)*3+3)=g.u.p(i);
    end
    
    for i=1:size(g.v.m,1)
        g.v.plot((i-1)*3+1)=g.v.m(i);
        g.v.plot((i-1)*3+2)=g.v.m(i)*NaN;
        g.v.plot((i-1)*3+3)=g.v.p(i);
    end
    
    for i=1:size(g.u.m,1)
        g.VectTplotGD((i-1)*3+1)=(i-1)*dt;
        g.VectTplotGD((i-1)*3+2)=(i-1)*dt;
        g.VectTplotGD((i-1)*3+3)=(i-1)*dt;
    end
    
    g.u.moy= zeros(size(g.u.m));
    g.u.moy(:,1)= g.u.p(:,1);
    g.u.moy(:,2:end-1)= (g.u.p(:,2:end-1)+g.u.m(:,2:end-1))/2;
    g.u.moy(:,end)= g.u.m(:,end);
    
    g.v.moy= zeros(size(g.v.m));
    g.v.moy(:,1)= g.v.p(:,1);
    g.v.moy(:,2:end-1)= (g.v.p(:,2:end-1)+g.v.m(:,2:end-1))/2;
    g.v.moy(:,end)= g.v.m(:,end);
    
    
end