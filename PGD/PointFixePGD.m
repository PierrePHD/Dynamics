function [HistKf,HistKg,ConvergPointFixe,Conditionnement,f_q,g_q,erreur] = PointFixePGD(Kmax,problem,calcul, m, HistMf, HistMg,OthoIntern,epsilon)

    SizeVectL = size(problem.VectL,2);
        
    erreur = 0;
    
    % Initialiser g(t) %, h(theta)
    g_q.w = ones(size( 0:calcul.dt:problem.Ttot ))';
    g_q.v = (0:calcul.dt:problem.Ttot)';
    g_q.u = 1/2*g_q.v.^2;
    
    K = [ problem.K0 problem.D' ; problem.D zeros(size(problem.D,1))];
    
    HistKf  =zeros(size(K,1),Kmax);
    %HistKg 	=zeros(size(g_q.u,1),Kmax);
    ConvergPointFixe = zeros(1,Kmax);
    Conditionnement  = zeros(1,Kmax);
        
    for k=1:Kmax
        [f_q,condi,erreur] = ProblemEspace(problem, g_q, m, calcul.dt, HistMf, HistMg);
        if (erreur) 
            disp(['Erreur PGD a   m = ' num2str(m) ' , k = ' num2str(k)]);
                %fileID = fopen('PGD.Conv.dat','a');
                %fprintf(fileID, num2str(m));
                %fclose(fileID);
                HistKf   = HistKf(:,1:(k-1));
                HistKg   = HistKg(:,1:(k-1));
            break;
        end
        if OthoIntern
            for i=1:(m-1)
                f_q(1:SizeVectL) = f_q(1:SizeVectL) - HistMf(1:SizeVectL,i)*(HistMf(1:SizeVectL,i)'*f_q(1:SizeVectL) );
            end
        end
        Conditionnement(k) = condi;
        if ~(norm(f_q)==0)
            f_q(1:SizeVectL) = f_q(1:SizeVectL) / norm(f_q(1:SizeVectL));
        end
        HistKf(:,k) = f_q;
        if m>1  % Enlever les multiplicateur de Lagrange
            HistMfg=HistMf(1:SizeVectL,:);
        else
            HistMfg=HistMf;
        end
        %disp(['---------Probleme en temps------------']);
        [g_q] = ProblemTemps(problem, f_q(1:SizeVectL,:), m, calcul.dt, HistMfg, HistMg, calcul.schem);

        HistKg(:,k)   = g_q ;

        if (k>1) 
            if (isa(g_q.u,'numeric') )
                ConvergPointFixe(k) = IntegrLine((g_q.u-HistKg(:,k-1).u),(g_q.u-HistKg(:,k-1).u),0,calcul.dt) * (f_q-HistKf(:,k-1))' *K* (f_q-HistKf(:,k-1));
            else
                Var1.m=g_q.u.m-HistKg(:,k-1).u.m;
                Var1.p=g_q.u.p-HistKg(:,k-1).u.p;
                Var2.m=g_q.u.m-HistKg(:,k-1).u.m;
                Var2.p=g_q.u.p-HistKg(:,k-1).u.p;
                ConvergPointFixe(k) = IntegrLine(Var1,Var2,0,calcul.dt) * (f_q-HistKf(:,k-1))' *K* (f_q-HistKf(:,k-1));
            end
            ConvergPointFixe(k) = ConvergPointFixe(k) / (IntegrLine( g_q.u,g_q.u ,0,calcul.dt) * f_q' *K* f_q);
            ConvergPointFixe(k) = sqrt(ConvergPointFixe(k)) ;
            if (k>2)
                if (ConvergPointFixe(k) < epsilon && ConvergPointFixe(k-1) < epsilon)
                    disp(['convergence apres ' num2str(k) ' iterations']);
                    break
                end
            end
        end
        if k==Kmax        
            disp(['ne convergence pas apres ' num2str(k) ' iterations']);
        end
    end
    
    
end