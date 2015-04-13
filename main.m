%% Warnings

% Utiliser "ceil" peut entrainer des erreur en arrondissansant 1000 a 1001.
%   Ici j'utilise "round" mais s'il vient a poser probleme lui aussi
%   choisir Ttot/calcul.dt entier.

% La correction des deplacements imposes n'est possible que si il ne sont
%   pas lies. !! Les deplacements imposes en PGD ne sont pas non plus
%   possibles si il y a plus d'une composante non nulle par ligne de D

% Les non-linearite ne sont pas traite automatiquement car il faut
%   re-appliquer les calcul.CL. impossible avec substitution pour l'instant.



   % schema d'integration :
    % 1 Newmark - Difference centree
    % 2 Newmark - Acceleration lineaire
    % 3 Newmark - Acceleration moyenne
    % 4 Newmark - Acceleration moyenne modifiee
    % 5 HHT-alpha
    % 6 Galerkin Discontinu
    % alpha : -1/3 <= alpha <= 0 
    
   % Solicitation
    % 1  Deformee de depart correspondant a un effort en bout de poutre puis relachee
    % 2  Effort sinusoidal en bout de poutre
    % 3  Deplacement impose en milieu de poutre
    % 4  Effort continue en bout de poutre
    % 5  Effort augmentant lineairement en bout de poutre
    % 6  Effort continue en bout de poutre les premiers pas de temps
          %cas.T = 2e-4;
    % 7  Vitesse initiale
    % 8  Une periode de sinusverse
          %cas.T =  % 10*calcul.dt < T < Ttot/4  
    % Masses-Ressorts
    % 10.01  Cas du cours par Louf
    % 10.1   Cas test 1
    % 10.2   Cas test 2 : Non lineaire
    


clear all
%clc
tic;
FRC = 1 ;       % Faire une Resolution Complete
FRPOD = 1 ;     % Faire une Resolution POD
FRPGD = 1 ;     % Faire une Resolution PGD
SolEx = 0 ;     % Utiliser une solution exacte connues

AffPOD = 1;
AffPGD = 1;

dt = 10e-8;%4e-6 ;
Ttot = 1000e-6 ;
schem.type = 3;
NbElem = 640;      % Nombre d element par partie de poutre

cas.type = 2;
    cas.AmpliF = 100 ;
    cas.T = 250e-6 ; 
    
M_POD = 1:100;         % Nombres de modes pour chaque resolution POD
M_PGD = 100;           % Nombres de modes pour     la resolution PGD

%% Cas Particulier

if (cas.type == 10.01 || cas.type == 10.02)
    dt = 5e-2 ;
    Ttot = 15 ;
    cas.AmpliF = 1 ;
    cas.T = 10; 
elseif (floor(cas.type) == 10)
    dt = 1e-3 ;
    Ttot = 1 ;
    cas.AmpliF = 10 ;
    cas.T = 2*pi/sqrt(1000); 
end

if (schem.type == 4 ||  schem.type == 5)
    schem.alpha = -3/9;
end


w = warning ('off','all');
% w = warning ('on','all');

addpath('Afficher','POD','PGD','Matlab2Tikz','Probleme')

% diary FichierLog
% fileID = fopen('PGD.Conv.dat','w');
%     fprintf(fileID,'Creation \n');
%     fclose(fileID);


                        %% Creation du probleme %%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

calcul = ParamCalcul(dt,schem,NbElem,Ttot);
disp(['schem.type = ' num2str(schem.type) '']);
            % *dt *schem *alpha *nombreElements *CL

calcul.cas = cas;

if (floor(cas.type) == 10)
    problem = MasseRessort(calcul);
    %problem = Poutre_MasseRessort(calcul);
else
    problem = Poutre(calcul);
end
    % *M *C *K0 *Ttot *VectL *D *conditionU *conditionV *conditionA *HistF 
    % *U0 *V0 *nonLinearite *verif

                       %% Solution Complete %%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if FRC
    method= struct('type',0);
    method.type = 1;
    SoluComplete = Resolution(calcul,problem,method);
end

% figure
% plot(SoluComplete.f.HistU(end-1,:))
% hold on;
% plot(SoluComplete.problem.HistF(end-1,:)/max(SoluComplete.problem.HistF(end-1,:))*max(SoluComplete.f.HistU(end-1,:)),'r')
% 
% 
% figure;
% plot(HistUExact(end-1,:));
% hold on;
% plot(SoluComplete.f.HistU(end-1,:),'r--');



%[HistUExact,HistVExact,HistAExact] = SolutionExacte(problem);


                      %% Reduction du modele %%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if FRPOD && FRC
    method= struct('type',0,'Modes',[],'Apriori',[]);
    method.type = 2;
    method.Modes = M_POD;%(size(M,1)-size(D,1));
    method.Apriori = SoluComplete.f.HistU';
    SoluPOD = Resolution(calcul,problem,method);
end
                             %% PGD %%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if FRPGD
    method= struct('type',0,'k',[],'m',[]);
    method.type = 3;
    method.k = 30;        % Nombre d'iterations max pour obtenir un mode
    method.m = M_PGD;     % Nombre de modes maximum
    method.OrthoExtern = 0;
    method.OrthoIntern = 0;
    SoluPGD = Resolution(calcul,problem,method);
end         

                       %% Solution Exacte %%
if SolEx
   % Sans ressort - E constant - Cas 4, 5 et 6
    if (cas.type == 4 || cas.type == 5 || cas.type == 6)
        [HistUExact,HistVExact,HistAExact] = SolutionExacte(calcul,problem);
        AfficherAnimation(SoluComplete.f.HistV,SoluPGD,problem,calcul);
    else
           SolutionExacteNonConnuePourCeCas;
    end
end

%% Affichage Complet

    Ref     = SoluComplete.f.HistU;
    MET     = [];   %ModesEspaceTemps
    ME      = [];   %ModesEspace
    MT      = [];   %ModesTemps
    Res     = []; %Resultat
    NDR     = 1;    %NoDisplayResultat 
    NDE     = 1;    %NoDisplayErreur
    OI      = struct('MET',0,'ME',0,'MT',0,'Res',0,'Err',0,'titre',''); %OutImage
    %titre = ['POD calcul.schem=' num2str(calcul.schem)];
    
    problemOrigin = problem;
    load('../Autres/Cluster/Rapatriement/Rapatri21/Exact640Ref1e7.mat', 'HistUExact', 'problem');
    Ref.f = HistUExact;
    VectT.Reference = 0:problem.calcul.dt:problem.calcul.Ttot;
    VectL.Reference = problem.VectL;
    Ref.VectT = 0:problem.calcul.dt:problem.calcul.Ttot;
    Ref.VectL = problem.VectL;
    
    VectT.Resultat = 0:dt:problemOrigin.calcul.Ttot ;
    VectL.Resultat = problemOrigin.VectL ;

    if (FRPOD && AffPOD)
        OI.titre = 'POD';
        Res     = SoluPOD(1).method.Modes; %Resultat
        ErrPOD = AfficherMethode(Ref,SoluPOD,MET,ME,MT,Res,NDR,NDE,OI);
    end
    if (FRPGD && AffPGD)
        OI.titre = 'PGD';
        ME      = [];%1:9;   %ModesEspace
        MT      = [];%1:9;   %ModesTemps
        Res     = 1:SoluPGD.Mmax; %Resultat   
        ErrPGD = AfficherMethode(Ref,SoluPGD,MET,ME,MT,Res,NDR,NDE,OI);
    end
%         SoluPGDHist  = zeros(size(problem.VectL,2),size(0:calcul.dt:problem.Ttot,2));
%         f=SoluPGD.HistMf(1:size(problem.VectL,2),1:SoluPGD.Mmax);
%         for l=1:SoluPGD.Mmax
%             g=SoluPGD.HistMg(l).u(:);
%             SoluPGDHist = SoluPGDHist +   (g*(f(:,l)'))'; %f(j,l)*g(k)
%         end   
%     ErrPGD = AfficherMethode(SoluPGDHist,SoluPGDOrtho,MET,ME,MT,Res,NDR,NDE);


% % Afficher Resultats MAsse-Ressort
%     if ((floor(cas.type) == 10) && (cas.type-10<0.1))
%         SoluPGDHist  = zeros(size(problem.VectL,2),size(0:calcul.dt:problem.Ttot,2));
%         f=SoluPGD.HistMf(:,1:SoluPGD.Mmax);
%         for l=1:2
%                 g=SoluPGD.HistMg(l).u(:);
%                 SoluPGDHist = SoluPGDHist +   (g*(f(:,l)'))'; %f(j,l)*g(k)
%                 
%             for i = 2:3
%                 
%                 figure('Name',['Deplacement noeud ' num2str(i) ' - m=' num2str(l) ''],'NumberTitle','off')
% 
%                 
%                 plot(0:calcul.dt:calcul.Ttot,SoluComplete.f.HistU(i,:),'LineWidth',3,'color','blue');
%                 hold on;
%                 plot(0:calcul.dt:calcul.Ttot,SoluPGDHist(i,:),'--','LineWidth',2,'color','red');
%             
%                 saveas(gcf, ['Images/Sortie/Sortie.Matlab.Noeud' num2str(i) '.m' num2str(l) '.HF.eps'], 'eps2c');
%                 
%             end
%         end
%     end

%save('OutPut')
toc
%exit;
return;

    OI      = 1;    %OutImage
                        %% Analyse des modes %%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   
ModePOD = (SoluPOD( size(SoluPOD,2) ).p )';
NbModesPOD= size(ModePOD,1);
NbModesPGD = SoluPGD.method.m;
ModePGD=zeros(NbModesPGD,size(problem.VectL,2));

for i=1:NbModesPGD
    ModePGD(i,:) = SoluPGD.HistMf(:,i)';  %SoluPGD.HistMf(1:size(problem.VectL,2),i)';
end

AnalyseDeMAC(NbModesPOD,NbModesPGD,ModePOD,ModePGD,OI,'POD','PGD');


return;
% fichier = ['Resultats' num2str(program+1)];
% save(fichier);

         



                          %% Solutions EF %%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for cacher=1:0
    erreurCarre=zeros(IterProgram,1);
    erreurAmpTotale=zeros(IterProgram,1);
% Il faut placer :
    % TablVectT{program+1}=0:calcul.dt:Ttot;
% et 
    % TablVectL{program+1}=[0:L/calcul.nombreElements:L L+Lres];
% dans la boucle du programme
    
    VectL = TablVectL{IterProgram};
    VectT = TablVectT{IterProgram};
    Reference = sortie(IterProgram).f.HistU ;    

    for i=1:0 %:IterProgram %nombre de calcul EF a afficher
        Resultat  = sortie(i).f.HistU ;
        NomFigure = ['Calcul sur modele EF a ' num2str(i, '%10.u\n') ' modes'];
        VectLR = TablVectL{i};
        VectTR = TablVectT{i};
        NoDisplayResultat = 0;
        
        [erreurCarre(i),erreurAmpTotale(i)] = AfficherSolutionDifferenteDiscretisation(Reference,Resultat,NomFigure,VectT,VectL,VectTR,VectLR,NoDisplayResultat);
    end
end

