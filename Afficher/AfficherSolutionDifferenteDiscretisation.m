function [erreurMaximale,erreurCarre, erreurAmpTotale] = AfficherSolutionDifferenteDiscretisation(Reference,Resultat,NomFigure,VectT,VectL,VectTR,VectLR,NoDisplay)

    if ~(size(VectLR,2) == size(VectL,2)) && ~(size(VectT,2) == size(VectTR,2))  
        Erreur('Vecteur Temps et espace differents')
    end
    
    if (size(VectLR,2) == size(VectL,2))  %Modele reduit
        %disp('Meme Vecteur Espace');     
        NewResult=Resultat;
    elseif (size(VectT,2) == size(VectTR,2))
        %disp('Differents Vecteurs Espace');
        NewResult = zeros(size(Reference));
        for j=1:size(VectL,2)
            MemeCompos = 0;
                for l=1:size(VectLR,2)
                    if (VectL(j) == VectLR(l))
                        NewResult(j,:)=Resultat(l,:);
                        MemeCompos = 1;
                        break;
                    end
                end
            if (MemeCompos==0)
                for l=1:size(VectLR,2)
                    if (VectLR(l) > VectL(j))

                        C1 =     (VectLR(l)  - VectL(j)) / ( VectLR(l) - VectLR(l-1) );
                        C2 = - ((VectLR(l-1) - VectL(j)) / ( VectLR(l) - VectLR(l-1) ));

                        for t=1:size(VectT,2)
                            NewResult(j,t)= C2*Resultat(l,t) + C1*Resultat(l-1,t);
                        end

                        break;
                    end
                end
            end
        end

    end

    if (size(VectT,2) == size(VectTR,2))                        
        %disp('Meme Vecteur Temps');
    elseif (size(VectLR,2) == size(VectL,2))
        %disp('Differents Vecteurs Temps');
        for j=1:size(VectT,2)
            MemeCompos = 0;
                for l=1:size(VectTR,2)
                    if (VectT(j) == VectTR(l))
                        NewResult(:,j)=Resultat(:,l);
                        MemeCompos = 1;
                        break;
                    end
                end
            if (MemeCompos==0)
                for l=1:size(VectTR,2)
                    if (VectTR(l) > VectT(j))
                        C1 =    ( VectTR(l)  - VectT(j) )/ ( VectTR(l) - VectTR(l-1) );
                        C2 = - ((VectTR(l-1) - VectT(j) )/ ( VectTR(l) - VectTR(l-1) ));
                        for x=1:size(VectL,2)
                            NewResult(x,j)= C2*Resultat(x,l) + C1*Resultat(x,l-1);
                        end
                        break;
                    end
                end
            end
        end
    end
        
    [erreurMaximale,erreurCarre, erreurAmpTotale] = AfficherSolutionSameSize(Reference,NewResult,NomFigure,VectT,VectL,NoDisplay);
                
end