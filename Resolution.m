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
        Solutions(1).method = method;
        if (reduc == 1)
            [Solutions(1).U_SVD,Solutions(1).S_SVD,Solutions(1).V_SVD]=svd(method.Apriori); 
        end
        for n = VectN  % taille de la base modale
            
            disp(['POD mod ' num2str(n) ])
            
            % Creation de la base reduite d une matrice de passage
                [PRT] = BaseReduite (reduc,n,problem,problem.D,method.Apriori);

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
                Solutions(n).calcul  = calcul;
                Solutions(n).problem = problem;
                Solutions(n).p = PRT;
                Solutions(n).f=resolutionTemporelle(calcul,problemReduit);
                
%                 M9= MR(1:n,1:n)*10000
%                 K9=K0R(1:n,1:n)/100000
%                 NN=zeros(1,n);
%                 for i=1:n
%                     NN(1,i)=sqrt(K0R(i,i)/MR(i,i));
%                 end
%                 NN
        end
        
        if (n~=VectN(end))
                    n=n-1;
                    disp(['Arret des resolution POD au mode= ' num2str(n) ' sur ' num2str(VectN(end))]);
                    j=0;
                    for i = method.Modes
                        if i > n
                            method.Modes = method.Modes(1:j);
                            Solutions(1).method = method;
                            break;
                        end
                        j=j+1;
                    end
                    method.Modes=1:n;
        end
    end
    
%% PGD

    if (method.type == 3)
        
        Solutions.calcul  = calcul;
        Solutions.problem = problem;
        Solutions.method  = method;
        
        epsilon = 10^-6;

        % Fonction f(X), g(t) %, h(theta)
        [HistMf,HistMg,HistTotf,HistTotg,TableConv,Mmax,erreur] = CalcModesPGD(method.m,method.k,problem,calcul,method.OrthoIntern,method.OrthoExtern,epsilon);
        Solutions.HistMf = HistMf;
        Solutions.HistMg = HistMg;
        Solutions.Mmax = Mmax;
    end    

end