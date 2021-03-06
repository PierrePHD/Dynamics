function [f_q,condi,erreur] = ProblemEspace(problem, g_q, m, dt, HistMf, HistMg)

    erreur=0;
    
    K = problem.K0;
    C = problem.C;
    M = problem.M;
    HistF = problem.HistF ;
    
    t0 = 0;
    
%% Premier membre
%     g_q.v  = DerivVect(g_q.u ,dt,5);
%     g_q.w = DerivVect(g_q.v,dt,5);
    Premier =           IntegrLine(g_q.u, g_q.u,t0,dt) * K ;
    Premier = Premier + IntegrLine(g_q.v, g_q.u,t0,dt) * C ;
    Premier = Premier + IntegrLine(g_q.w ,g_q.u,t0,dt) * M ;
    Premier = [ Premier problem.D' ; problem.D zeros(size(problem.D,1))];
    condi=rcond(Premier);

%% Second membre
    sum = zeros( size(HistF(:,1)) );
    Second = sum;
    for i=1:(m-1)
        g_k_q = HistMg(:,i).u;
        f_k_q = HistMf(:,i);
%         
%         size(HistF(:,1))
%         size(f_k_q)
%         size(Premier)
%         fff
        sum = sum + IntegrLine(g_k_q,  g_q.u,t0,dt) * f_k_q;
    end
    Second = Second - K * sum;
    sum1=sum;
    
    sum = zeros( size(HistF(:,1)) );
    for i=1:(m-1)
        %g_k_q  = HistMg(:,i);
        %g_kp_q  = DerivVect(g_k_q ,dt,5);
        g_kp_q = HistMg(:,i).v;
        f_k_q  = HistMf(:,i);
        sum = sum + IntegrLine(g_kp_q,  g_q.u,t0,dt) * f_k_q;
    end
    Second = Second - C * sum;
    sum2=sum;
    
    sum = zeros( size(HistF(:,1)) );
    for i=1:(m-1)
        %g_k_q = HistMg(:,i);
        %g_kp_q   = DerivVect(g_k_q  ,dt,5);
        %g_kp_q = HistMgp(:,i);
        %g_kpp_q  = DerivVect(g_kp_q ,dt,5);
        g_kpp_q = HistMg(:,i).w;
        f_k_q = HistMf(:,i);
        sum = sum + IntegrLine(g_kpp_q,  g_q.u,t0,dt) * f_k_q;
    end
    Second = Second - M * sum;
    sum3=sum;
    
    sum = zeros( size(HistF(:,1)) );
    for i=1:size(HistF,1)   % Intralge sur chaque composante de F(t)
        E_i = zeros( size(HistF(:,1)) );
        E_i(i) = 1;
        F_i = HistF(i,:)';
        sum = sum + IntegrLine(F_i,  g_q.u,t0,dt) * E_i;
    end
    Second = Second + sum;
    sum4=sum;
    
    %size(problem.conditionU,1)
    sumConditionU=0;
    for i=1:size(size(problem.conditionU,1),1)   % Intralge sur chaque composante de F(t)
        E_i = zeros( size(problem.conditionU(:,1)) );
        E_i(i) = 1;
        C_i = problem.conditionU(i,:)';
        sumConditionU = sumConditionU + IntegrLine(C_i, (C_i*0)+1,t0,dt) * E_i;
    end
    
    %HistF = [ problem.HistF ; problem.conditionU ] ;
    %size(Second)
    Second = [ Second ; sumConditionU ] ;
    
%% Resolution

    f_q = Premier\Second;
    if isnan(f_q(1))
        Second
        sum1
        sum2
        sum3
        sum4
        erreur = 1;
        f_q = zeros( size(HistF(:,1)) );
        condi = 0;
        return
    end
    f_q = f_q(1:size(K,1));
    
end