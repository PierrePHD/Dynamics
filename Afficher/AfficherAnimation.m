function [] = AfficherAnimation(Reference1,Resultat,problem,calcul);
                
    % Sans ressort - E constant - Cas 4, 5 et 6
    [HistUExact,Reference2,HistAExact] = SolutionExacte(calcul,problem);
    
    if Resultat.method.type == 3
        n = Resultat.method.m;
        ResultatTX  = zeros(size(problem.VectL,2),size(0:calcul.dt:problem.Ttot,2));
        f=Resultat.HistMf(1:size(problem.VectL,2),1:n);
        for l=1:n
            if (isa(Resultat.HistMg(l).u,'numeric') )
                g=Resultat.HistMg(l).v(:);
            else
                g=Resultat.HistMg(l).v.moy(:);
            end
            ResultatTX = ResultatTX + (g*(f(:,l)'))';
        end
    elseif Resultat.method.type == 2
        ResultatTX = Resultat.p*Resultat.f.HistV;
    end


    amp1 = max(Reference1(:)) - min(Reference1(:));
    amp2 = max(Reference2(:)) - min(Reference2(:));
    amp3 = max(ResultatTX(:)) - min(ResultatTX(:));

    mini  = min(Reference1(:))-0.1*amp1;
    maxi  = max(Reference1(:))+0.1*amp1;
    mini2 = min(Reference2(:))-0.1*amp2;
    maxi2 = max(Reference2(:))+0.1*amp2;
    mini3 = min(ResultatTX(:))-0.1*amp3;
    maxi3 = max(ResultatTX(:))+0.1*amp3;
    miniT = min([mini;mini2;mini3]);
    maxiT = max([maxi;maxi2;maxi3]);

    figure('Name','Animation : onde longitudinale dans la poutre sur base reduite','NumberTitle','off')
    for i=1:size(Reference1,2)
        if isempty(Reference2)
            plot(problem.VectL,Reference1(:,i),'r',problem.VectL,ResultatTX(:,i),'b');
        else
            plot(problem.VectL,Reference1(:,i),'r',problem.VectL,Reference2(:,i),'k',problem.VectL,ResultatTX(:,i),'b');
        end
        axis([0 problem.VectL(end) miniT maxiT ]);
        xlabel('x');
        ylabel('u(x,t)');
        %legend('Reference',['Resultat, avec ' num2str(size(PRT,2)) ' modes']);
        pause(0.4);
    end

end
