function [HistMf,HistMg,HistTotf,HistTotg,TableConv,Mmax,erreur] = CalcModesPGD(Mmax,Kmax,problem,calcul,OthoIntern,OrthoExtern,epsilon)
        
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
        
    HistMf    =zeros(SizeVectL,Mmax);

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
    HistKf = [];
    
    mMin=-1; % Nombre de mode ajoutes avant le point fixe - calculee apres
    LectureConditionU =1;
    m=0;
    while m<Mmax
        m=m+1;
        disp(['m = ' num2str(m)]);
        
        if initU
            initU=0;
            HistKf = [];
            HistKg  = [];
            f_q = problem.U0 ;
            g_q.u = ones(SizeVectT,1);
            g_q.u = g_q.u * norm(f_q);
            f_q = f_q / norm(f_q);
            g_q.v = zeros(SizeVectT,1);
            g_q.w = zeros(SizeVectT,1);
            
            %g_q.u = zeros(SizeVectT,1);
            %g_q.u(1) = 1;
            
        elseif initV
            initV=0;
            HistKf = [];
            HistKg  = [];
            f_q = problem.V0 ;
            g_q.u = zeros(SizeVectT,1);
            g_q.v = ones(SizeVectT,1);
            %g_q.v = zeros(SizeVectT,1);
            %g_q.v(1) = 1;
            g_q.v = g_q.v * norm(f_q);
            g_q.u = (0:calcul.dt:problem.Ttot)' * norm(f_q);
            f_q = f_q / norm(f_q);
            g_q.w = zeros(SizeVectT,1);
            
        elseif norm(conditionU(LectureConditionU:end,:)) %&& LectureConditionU <= size(conditionU,1)
            for i=LectureConditionU:size(conditionU,1) % \
                if norm(conditionU(i,:))               % / eviter les lignes nulles (causee par les encastrement imposes par multiplicateurs
                    HistKf = [];
                    HistKg  = [];
                    f_q = problem.D(i,:)' ;
                    g_q.u = conditionU(i,:);
                    g_q.u = g_q.u * norm(f_q);
                    f_q = f_q / norm(f_q);
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
            if (~size(HistKf,1)) % Si n a pas encore ete rempli par un point fixe
                mMin=m-1;
            end
            if m==1
                [HistKf,HistKg,TableConv(m,:),TableCondi(m,:),f_q,g_q,erreur] = PointFixePGD(Kmax,problem,calcul, m, HistMf,     [],OthoIntern,epsilon);
            else
                [HistKf,HistKg,TableConv(m,:),TableCondi(m,:),f_q,g_q,erreur] = PointFixePGD(Kmax,problem,calcul, m, HistMf, HistMg,OthoIntern,epsilon);
            end
        end
        
        if (mMin<0 && calcul.schem==6)
            g_q.u.m=g_q.u;
            g_q.u.p=g_q.u.m;
            g_q.u.moy=g_q.u.m;
            g_q.v.m=g_q.v;
            g_q.v.p=g_q.v.m;
            g_q.v.moy=g_q.v.m;
            VectTplot = 0:problem.calcul.dt:problem.Ttot;
            concatener = [VectTplot;VectTplot;VectTplot];
            g_q.VectTplotGD = concatener(:);
        end
        
        epsilon =1;
        
        % Doit on orthogonaliser les modes initiaux / deplacement imposes ? N
        %                        les modes trouves par rapport aux modes
        %                        initiaux / deplacement imposes ? ??
        %         eviter la polution des petit changements ? O  10%
        % Ne pas tenir compte des multiplicateur en fin de f_q ? N
%         [HistMg,f_q,g_q,epsilon] = OrthoPGD(HistMf,HistMg,m,mMin,f_q,g_q,SizeVectL);
%         f_q = f_q / norm(f_q);
        
        if (mMin >= 0 && m > (mMin+1) && OrthoExtern)
            [HistMg,f_q,g_q,epsilon] = OrthoPGD(HistMf,HistMg,m,mMin,f_q,g_q);
        end
        
        if (erreur)
            Mmax = m-1;
            break;
        end
        
        if epsilon > 0
            HistTotf{m} = HistKf;
            HistTotg{m}   = HistKg;
            HistMf(:,m) = f_q;
            HistMg(m) = g_q  ;
        else
            m = m-1;
        end
        
        
    end
    HistMf = HistMf(1:SizeVectL,:); % Retire les multiplicateurs

end