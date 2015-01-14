function [MR,CR,K0R,U0R,V0R,DR,HistFR,nonLineariteR,PresenceNan] = Projection(PRT,problem)


        MR  = PRT'*problem.M*PRT;
        CR  = PRT'*problem.C*PRT;
        K0R = PRT'*problem.K0*PRT; 
        
        if (problem.nonLine==1)
            % Ajout du ressort
            nonLineariteR(1).scalaires      = problem.nonLinearite(1).scalaires; 
            nonLineariteR(1).matriceKUnit   = PRT'*problem.nonLinearite(1).matriceKUnit*PRT; 
            nonLineariteR(1).dependanceEnU  = PRT'*problem.nonLinearite(1).dependanceEnU;
            nonLineariteR(1).fonction       = problem.nonLinearite(1).fonction ;
        else
            nonLineariteR(1) = problem.nonLinearite(1);
        end
        
        HistFR  = PRT'*problem.HistF;
        U0R     = PRT'*problem.U0;
        V0R     = PRT'*problem.V0;
        test = isnan(U0R);
        PresenceNan = sum(test);
        if (size(problem.D,1))
            DR=problem.D*PRT;
        else    
            DR=[];
        end
end