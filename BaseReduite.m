function [PRT] = BaseReduite (reduc,TailleBase,problem,D,Donnees)

        if ((TailleBase+size(D,1))>size(problem.M,1))
            fprintf('\nNombre de noeuds insuffisant\n\n(TailleBase+size(D,1))>nombreNoeuds\n\n');
            return;
        end
        PRT =zeros(size(problem.M,1),TailleBase+size(D,1)); % Matrice de Passage 
                                           % de la base Reduite a la base Totale

        if (reduc == 1)         % SVD
            [~,~,V_SVD]=svd(Donnees);
            for i=1:TailleBase
                ModeEspace = V_SVD(:,i)';
                PRT(:,i) = ModeEspace /norm(ModeEspace); 
            end

        elseif (reduc == 2)     % Rayleigh-Ritz
            [Famille,~]=AnalyseRR(TailleBase,problem.M,problem.K0,problem.conditionU,D,problem.VectL);
            if (size(Famille,2) >= TailleBase)
                PRT(:,1:TailleBase) = Famille(:,1:TailleBase);
            else
                fprintf('Il y a moins de mode trouves par Rayleigh que la taille souhaitee de reduction\n');
                return;
            end
            
        elseif (reduc == 3)     % PGD
            if (Mmax >= TailleBase)                
                for i=1:TailleBase
                    ModeEspace = HistMfOrth(1:size(problem.VectL,2),i)';
                    PRT(:,i) = ModeEspace /norm(ModeEspace); 
                end
            else
                fprintf('Il y a moins de mode PGD que la taille souhaitee de reduction\n');
                return;
            end
        end

        % On ajoute a la base les "modes" de deplacements imposes
        for j=1:size(D,1)
            for k=1:size(PRT,2)
                if (k<(TailleBase+j))
                    %x = PRT(:,k) - D(j,:)'*(D(j,:)/((norm(D(j,:)))^2) * PRT(:,k))
                    x = PRT(:,k) - (D(j,:)* PRT(:,k)/norm(D(j,:))) * (D(j,:)'/norm(D(j,:)));
                    PRT(:,k) = x/norm(x);
                end
            end
            PRT(:,TailleBase+j)=(D(j,:)/norm(D(j,:)))';
        end        
        % On reorthogonalise les modes altere par la boucle precedente
        for j=2:TailleBase
            x = PRT(:,j);
            for k=1:(j-1)
                x = x - (PRT(:,k)'* x/norm(PRT(:,k))) * (PRT(:,k)/norm(PRT(:,k)));
            end
            PRT(:,j) = x/norm(x);
        end
end