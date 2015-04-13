function [erreurMaximale,erreurVol,erreurAmpTotale] = AfficherSolutionSameSize(Reference,Resultat,NomFigure,VectT,VectL,NoDisplay)

    s(3)=struct('f',[],'a',0);
                                 
    if ~NoDisplay
        figure('Name',NomFigure,'NumberTitle','off')
    end
    for i=1:3
        if (i ==1)
            s(i).f=Reference;
        elseif (i ==2)
            s(i).f=Resultat;
        elseif (i ==3)
            s(i).f= (s(1).f - s(2).f);
        end

        s(i).a = max(s(i).f(:)) - min(s(i).f(:));   % amplitude

        if ~NoDisplay
            subplot(2,2,i);
                if s(i).a == 0
                    zoom=0;
                else
                    zoom = -floor(log(s(i).a)/log(10)) ;
                end
                surf(VectT,VectL,(s(i).f*(10^zoom)),'EdgeColor','none');
                    
                xlabel('t');
                ylabel('x');
                zlabel(['u(x,t)*10^' num2str(zoom) ]);

                if (s(i).a == 0)
                    axis([0 VectT(end) 0 VectL(end) (s(i).f(1,1)-1) (s(i).f(1,1)+1)]);
                else
                    axis([0 VectT(end) 0 VectL(end) (min(s(i).f(:))-0.1*s(i).a)*(10^zoom) (max(s(i).f(:))+0.1*s(i).a)*(10^zoom)]);
                end

                if (i ==1)
                    title(['Solution de Reference, d amplitude ' num2str(s(1).a, '%10.1e\n') ]);
                elseif (i ==2)
                    title(['Resultat, d amplitude ' num2str(s(2).a, '%10.1e\n') ]);
                elseif (i ==3)
                    title(['Difference, d amplitude ' num2str((s(3).a)*100/s(1).a, '%2.2g\n') '% de l amplitude Ref' ]);
                end
            %set(gca, 'FontSize', 20);
        end
    end

    erreurMaximale = max(abs(s(3).f(:)))/s(1).a;
    DiffAmp = (s(1).a - s(2).a)/s(1).a;
    %DiffVol = sqrt(sum(sum((s(3).f).^2))/sum(sum((s(1).f).^2)));
    %erreurCarre = abs(DiffVol);
    DiffVol = sum(sum(abs(s(3).f)))/sum(sum(abs(s(1).f)));
    erreurVol = abs(DiffVol);
    erreurAmpTotale = abs(DiffAmp);
    
    if ~NoDisplay    
        ax = subplot(2,2,4);
        text(0,0,['Erreur sur l amplitude totale ' num2str(abs(DiffAmp)*100, '%2.2g\n') '%' ]);
        text(0,0.12,['Erreur volume au carre ' num2str(abs(DiffVol)*100, '%2.2g\n') '%' ]);
        text(0,0.24,['Erreur relative max ' num2str(erreurMaximale*100, '%2.2g\n') '%' ]);
        set ( ax, 'visible', 'off')
        title(['Erreur sur l amplitude totale ' num2str(abs(DiffAmp)*100, '%2.2g\n') '%' ]);
    end
        
end
