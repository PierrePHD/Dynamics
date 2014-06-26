function [HistMf,HistMg,HistTotf,HistTotg,TableConv,Mmax,erreur] = CalcModesPGD(Mmax,Kmax,problem,calcul,OthoIntern,epsilon)
        
    SizeVectL = size(problem.VectL,2); 
    SizeVectT = size(problem.HistF,2);
    SizeD =   size(problem.D,1);
    conditionU = problem.conditionU;
    
    erreur = 0;
    
    if norm(problem.U0) ;     Mmax = Mmax + 1; end;
    if norm(problem.V0) ;     Mmax = Mmax + 1; end;
    if norm(conditionU(1:end,:))
        for i=1:size(conditionU,1) 
            if norm(conditionU(i,:))  
                Mmax = Mmax + 1;
            end
        end  
    end
    
    if norm(conditionU)     
        if ~problem.verif    
            ErreurVerifConditionDeplacementNonPriseEnCompte;
        end
        
        for i=1:size(conditionU,1)
            if norm(conditionU(i,:))
                Mmax = Mmax + 1;
            end
        end
        
    end
        
    HistMf    =zeros(SizeVectL+SizeD,Mmax);

    HistTotf=cell(1,Mmax);
    HistTotg  =cell(1,Mmax);


    TableCondi = zeros(Mmax,Kmax);
    TableConv =  zeros(Mmax,Kmax);

    if norm(problem.U0)
        initU=1;
    else
        initU=0;
    end
    
    if norm(problem.V0)
        initV=1;
    else
        initV=0;
    end
    
    LectureConditionU =1;
    for m=1:Mmax
        disp(['m = ' num2str(m)]);
        
        if initU
            initU=0;
            HistKf = [];
            HistKg  = [];
            f_q = [problem.U0 ; zeros(SizeD,1)] ;
            g_q.u = ones(SizeVectT,1);
            g_q.u = g_q.u * norm(f_q(1:SizeVectL));
            f_q = f_q / norm(f_q(1:SizeVectL));
            g_q.v = zeros(SizeVectT,1);
            g_q.w = zeros(SizeVectT,1);
            
        elseif initV
            initV=0;
            HistKf = [];
            HistKg  = [];
            f_q = [problem.V0 ; zeros(SizeD,1)] ;
            g_q.u = zeros(SizeVectT,1);
            g_q.v = ones(SizeVectT,1);
            %g_q.v = zeros(SizeVectT,1);
            %g_q.v(1) = 1;
            g_q.v = g_q.v * norm(f_q(1:SizeVectL));
            g_q.u = (0:calcul.dt:problem.Ttot)' * norm(f_q(1:SizeVectL));
            f_q = f_q / norm(f_q(1:SizeVectL));
            g_q.w = zeros(SizeVectT,1);
            
        elseif norm(conditionU(LectureConditionU:end,:)) %&& LectureConditionU <= size(conditionU,1)
            for i=LectureConditionU:size(conditionU,1) % \
                if norm(conditionU(i,:))               % / eviter les lignes nulles (causee par les encastrement imposes par multiplicateurs
                    HistKf = [];
                    HistKg  = [];
                    f_q = [problem.D(i,:)' ; zeros(SizeD,1) ];
                    g_q.u = conditionU(i,:);
                    g_q.u = g_q.u * norm(f_q(1:SizeVectL));
                    f_q = f_q / norm(f_q(1:SizeVectL));
                    g_q.v = zeros(SizeVectT,1);
                    g_q.w = zeros(SizeVectT,1);
            
                    LectureConditionU = i + 1;
                    break
                elseif i>=size(conditionU,1)
                    % LectureConditionU = size(conditionU,1) + 1;
                    Il.y.a.une.erreur
                end
            end            
        else
            if m==1
               %[HistKf,HistKg,TableConv(m,:),TableCondi(m,:),f_q,g_q,erreur] = PointFixePGD(Kmax,M, C, K0, HistF, D, conditionU, m, dt, HistMf,     [],OthoIntern,VectL,epsilon,Ttot,schem);
                [HistKf,HistKg,TableConv(m,:),TableCondi(m,:),f_q,g_q,erreur] = PointFixePGD(Kmax,problem,calcul, m, HistMf,     [],OthoIntern,epsilon);
            else
               %[HistKf,HistKg,TableConv(m,:),TableCondi(m,:),f_q,g_q,erreur] = PointFixePGD(Kmax,M, C, K0, HistF, D, conditionU, m, dt, HistMf, HistMg,OthoIntern,VectL,epsilon,Ttot,schem);
                [HistKf,HistKg,TableConv(m,:),TableCondi(m,:),f_q,g_q,erreur] = PointFixePGD(Kmax,problem,calcul, m, HistMf, HistMg,OthoIntern,epsilon);
            end
        end
        if (~size(HistKf,1) && calcul.schem==6)
            g_q.u.m=g_q.u;
            g_q.u.p=g_q.u.m;
            g_q.u.moy=g_q.u.m;
            g_q.v.m=g_q.v;
            g_q.v.p=g_q.v.m;
            g_q.v.moy=g_q.v.m;
        end
        
        
        
        % norme_f_q=norm(f_q(1:SizeVectL))-1
        % f_q(1:SizeVectL) = f_q(1:SizeVectL) / norm(f_q(1:SizeVectL)); 
        % norme_f_q=norm(f_q(1:SizeVectL))-1
        
        HistTotf{m} = HistKf;
        HistTotg{m}   = HistKg;
        if (erreur)
            Mmax = m-1;
            break;
        end
        HistMf(:,m) = f_q;
        HistMg(m) = g_q  ; 
    end
    HistMf = HistMf(1:SizeVectL,:); % Retire les multiplicateurs

end