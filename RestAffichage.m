
    %disp(['Estimation du temps de calcul sur base complete ' num2str(Tcalcul, '%10.1e\n') 's']);
    figure('Name',['Calcul de choc calcul.schem ' num2str(calcul.schem) ],'NumberTitle','off')
     surf(0:calcul.dt:problem.Ttot,problem.VectL,sortie(1).f.HistU,'EdgeColor','none');
     %plot(0:calcul.dt:problem.Ttot,sortie(1).f.HistU(40,:),0:calcul.dt:problem.Ttot,sortie(1).f.HistU(end-1,:),'r',0:calcul.dt:problem.Ttot,(problem.HistF(end-1,:)/(2*AmpliF))*max(sortie(1).f.HistU(end-1,:)),'LineWicalcul.dth',2);
     chainetitre=['calcul.schema Newmark - Acceleration moyenne, T=' num2str(problem.Ttot, '%10.1e\n') ', calcul.dt=' num2str(calcul.dt, '%10.1e\n')];
    title(chainetitre);  
        set(gca, 'FontSize', 20);
        
%         
%         matlab2tikz( ['../Latex/Calculcalcul.schem3.T1.calcul.dt' num2str(calcul.dt) '.tikz'] );
     

% 
% for i=0:1

%     figure('Name','Difference entre U_m et U_p','NumberTitle','off')
%      surf(0:calcul.dt:Ttot,VectL,(sortie(1).f.HistU_m - sortie(1).f.HistU_p),'EdgeColor','none');
%         return;
        

%% Solution Exacte

    % Sans ressort - Cas 4, 5 et 6
%     VectT=0:calcul.dt:problem.Ttot;
%     [HistUExact,HistVExact,HistAExact] = SolutionExacte(cas,c,AmpliF,Egene,Sec,L,VectL,VectT,calcul.dt,NbPas6);



%% Animation
    for i=1:0%VectN % Animation
        Reference1 = sortie(1).f.HistV;
        Reference2 = HistVExact;
        Resultat = sortie(1+i).p*sortie(1+i).f.HistV;

        AfficherAnimation(Reference1,Reference2,Resultat,VectL,L);
    end
    
    
    %% Affichage Complet POD

    Reference = sortie(1).f.HistU;
    ModesEspaceTemps = [];
    ModesEspace = [];
    ModesTemps = [];
    Resultat = method.VectN;
    NoDisplayResultat = 1;
    NoDisplayErreur = 1;
    Methode = 1; % POD
    chainetitre = ['POD calcul.schem=' num2str(calcul.schem)];

    [ErrMaxPOD,ErrCarrePOD,ErrAmpTotalePOD] = AfficherMethode(calcul.dt,problem.Ttot,problem.VectL,sortie(1).f.HistU',SoluPOD,Reference,Resultat,ModesEspaceTemps,ModesEspace,ModesTemps,NoDisplayResultat,NoDisplayErreur,Methode,problem.D,cas,chainetitre);
    progSortie(program+1).e=ErrMaxPOD;
    


    figure('Name',['Calcul du cas ' num2str(cas) 'T=' num2str(T8, '%10.1e\n') ', calcul.dt=' num2str(calcul.dt, '%10.1e\n')],'NumberTitle','off')
    for i=1:2
     subplot(1,2,i);
     plot(0:calcul.dt:Ttot,progSortie(i).f.HistU(40,:),0:calcul.dt:Ttot,progSortie(i).f.HistU(end-1,:),'r',0:calcul.dt:Ttot,(HistF(end-1,:)/(2*AmpliF))*max(progSortie(i).f.HistU(end-1,:)),'LineWicalcul.dth',2);
     chainetitre=['calcul.schema ' num2str(progSortie(i).s) ];
     title(chainetitre);  
     set(gca, 'FontSize', 20);
    end
    
    figure('Name',['Erreur du cas ' num2str(cas) 'T=' num2str(T8, '%10.1e\n') ', calcul.dt=' num2str(calcul.dt, '%10.1e\n')],'NumberTitle','off')
     %chainetitre=['calcul.schema ' num2str(progSortie(i).s) ];
     title('Log of Maximal Error');  
     plot(Resultat,log(abs(progSortie(1).e))/log(10),'LineWicalcul.dth',2);
     hold;
     plot(Resultat,log(abs(progSortie(2).e))/log(10),'r','LineWicalcul.dth',2);
     legend(['calcul.schema ' num2str(progSortie(1).s) ],['calcul.schema ' num2str(progSortie(2).s) ]);
     set(gca, 'FontSize', 20);
     
     
     
     %% Affichage Complet PGD

        

        Reference = SoluComplete.HistU;
        ModesEspaceTemps = [];
        ModesEspace = [];
        ModesTemps = [];
        Resultat = 1:method.m;
        NoDisplayResultat = 1;
        NoDisplayErreur = 0;
        Methode = 2; % PGD
        chainetitre = ['PGD_calcul.schem=' num2str(calcul.schem)];
        
        % AfficherPGD(calcul.dt,Ttot,VectL,HistMf(1:size(VectL,2),:),HistMg,Reference,NombreResultat,ModesEspaceTemps,ModesEspace,ModesTemps,NoDisplayResultat);
            [ErrMaxPGD,ErrCarrePGD,ErrAmpTotalePGD] = AfficherMethode(calcul.dt,problem.Ttot,problem.VectL,SoluPGD.HistMf(1:size(problem.VectL,2),:),SoluPGD.HistMg,Reference,Resultat,ModesEspaceTemps,ModesEspace,ModesTemps,NoDisplayResultat,NoDisplayErreur,Methode,problem.D,cas,chainetitre);
            %matlab2tikz( ['../Latex/CalculConv.' num2str(calcul.dt) '.tikz']);
            
        % Convergence du point fixe
            for i=1:0 % 1:NombreResultat
                figure('Name',['Norme du couple '  num2str(i) ' dans le point fixe' ],'NumberTitle','off')
                plot(TableConv(i,:))
            end

    %% Animation
    
        for i=1:0%Mmax
            Reference1 = sortie(1).f.HistU;
            Reference2 = HistUExact;
            Resultat  = zeros(size(VectL,2),size(0:calcul.dt:Ttot,2));
                f=HistMf(1:size(VectL,2),1:i);
                g=HistMg(:,1:i);
                for j=1:size(VectL,2)
                    for k=1:1:size(0:calcul.dt:Ttot,2)
                        for l=1:i
                            Resultat(j,k) = Resultat(j,k) + f(j,l)*g(k,l);
                        end
                    end
                end

            AfficherAnimation(Reference1,Reference2,Resultat,VectL,L);
        end