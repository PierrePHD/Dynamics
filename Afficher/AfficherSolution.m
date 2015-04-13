function [erreurMaximale,ErreurVol,erreurAmpTotale] = AfficherSolution(Reference,Resultat,NomFigure,VectT,VectL,NoDisplay)
    if isequal(size(Reference),size(Resultat))
        [erreurMaximale,ErreurVol,erreurAmpTotale] = AfficherSolutionSameSize(Reference,Resultat,NomFigure,VectT.Resultat,VectL.Resultat,NoDisplay);
    else
        
        if size(Reference,1)==size(Resultat,1)
            Ref2 = Reference;
            Res2 = Resultat;
        elseif (VectL.Resultat(2) < VectL.Reference(2)) %&& (ceil(VectL.Reference(2)/VectL.Resultat(2)) == VectL.Reference(2)/VectL.Resultat(2))
            scale=VectL.Reference(2)/VectL.Resultat(2);
            Res2 = Resultat(1:scale:(end-1),:);
            Res2 = [ Res2(:,:) ; Resultat(end,:) ];
            Ref2 = Reference;
            VectL.Resultat=VectL.Reference;
        elseif (VectL.Resultat(2) > VectL.Reference(2)) %&& (ceil(VectL.Resultat(2)/VectL.Reference(2)) == VectL.Resultat(2)/VectL.Reference(2))
            scale=VectL.Resultat(2)/VectL.Reference(2);
            Ref2 = Reference(1:scale:(end-1),:);
            Ref2 = [ Ref2(:,:) ; Reference(end,:) ];
            Res2 = Resultat;
        else
            Erreur('Utiliser AfficherSolutionDifferenteDiscretisation')
        end
        
        
        if size(Reference,2)==size(Resultat,2)
            Ref3 = Ref2;
            Res3 = Res2;
        elseif (VectT.Resultat(2) < VectT.Reference(2)) %&& (ceil(VectT.Reference(2)/VectT.Resultat(2)) == VectT.Reference(2)/VectT.Resultat(2))
            scale=VectT.Reference(2)/VectT.Resultat(2);
            Res3 = Res2(:,1:scale:end);
            Ref3 = Ref2;
            VectT.Resultat=VectT.Reference;
        elseif (VectT.Resultat(2) > VectT.Reference(2)) %&& (ceil(VectT.Resultat(2)/VectT.Reference(2)) == VectT.Resultat(2)/VectT.Reference(2))
            scale=VectT.Resultat(2)/VectT.Reference(2);
            Ref3 = Ref2(:,1:scale:end);
            Res3 = Res2;
        else
            Erreur('Utiliser AfficherSolutionDifferenteDiscretisation')
        end
        
    %     if size(Reference,2)==size(Resultat,2)
    %         Ref3 = Ref2;
    %     elseif ceil(VectT.Resultat(2)/VectT.Reference(2)) == VectT.Resultat(2)/VectT.Reference(2)
    %         scale=VectT.Resultat(2)/VectT.Reference(2);
    %         Ref3 = Ref2(:,1:scale:end);
    %     else
    %         Erreur('Utiliser AfficherSolutionDifferenteDiscretisation')
    %     end
    
        [erreurMaximale,ErreurVol,erreurAmpTotale] = AfficherSolutionSameSize(Ref3,Res3,NomFigure,VectT.Resultat,VectL.Resultat,NoDisplay);
    end
end
