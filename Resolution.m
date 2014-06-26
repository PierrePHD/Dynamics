function [Solutions] = Resolution(calcul,problem,method)

%% Base complete

    if (method.type == 1)
        Solutions.calcul  = calcul;
        Solutions.problem = problem;
        Solutions.method  = method;
        Solutions.f = resolutionTemporelle(calcul,problem);
    end

%% POD

    if (method.type == 2)
        
        reduc = 1;
        % 1 POD
        % 2 Rayleigh
        % 3 PGD
        VectN = method.Modes;
        for n = VectN  % taille de la base modale
            
            Solutions(n).calcul  = calcul;
            Solutions(n).problem = problem;
            method.Modes = n;
            Solutions(n).method = method;
            
            % Creation de la base reduite d une matrice de passage
                [PRT] = BaseReduite (reduc,n,problem,problem.D,method.Apriori);
                Solutions(n).p = PRT;

            % Projection

                [MR,CR,K0R,U0R,V0R,DR,HistFR,nonLineariteR,PresenceNan] = Projection(PRT,problem);
                if PresenceNan
                    disp('Presence of a NaN - Resolution.m');
                    break;
                end

            % Resolution Temporelle sur base Reduite
            
                %Solutions(1+n).f=resolutionTemporelle(calcul.schem,calcul.alpha,MR,CR,K0R,calcul.dt,problem.Ttot,HistFR,U0R,V0R,problem.conditionU,problem.conditionV,problem.conditionA,DR,problem.nonLine,nonLineariteR,problem.verif);
                problemReduit = problem;
                problemReduit.M = MR;
                problemReduit.C = CR;
                problemReduit.K0 = K0R;
                problemReduit.U0 = U0R;
                problemReduit.V0 = V0R;
                problemReduit.D = DR;
                problemReduit.HistF = HistFR;
                problemReduit.nonLinearite = nonLineariteR;
                Solutions(n).f=resolutionTemporelle(calcul,problemReduit);
                
        end
        
        if (n~=VectN(end))
                    n=n-1;
                    disp(['Arret des resolution POD au mode= ' num2str(n) ' sur ' num2str(VectN(end))]);
                    method.VectN=1:n;
        end
    end
    
%% PGD

    if (method.type == 3)
        
        Solutions.calcul  = calcul;
        Solutions.problem = problem;
        Solutions.method  = method;
        
        OthoIntern = 0;
        
        epsilon = 10^-6;

        % Fonction f(X), g(t) %, h(theta)
        [HistMf,HistMg,HistTotf,HistTotg,TableConv,Mmax] = CalcModesPGD(method.m,method.k,problem,calcul,OthoIntern,epsilon);
        Solutions.HistMf = HistMf;
        Solutions.HistMg = HistMg;
        Solutions.Mmax = Mmax;
    end    

end