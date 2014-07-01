
%% Probleme de reference

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
    % 1 Deformee de depart correspondant a un effort en bout de poutre puis relachee
    % 2 Effort sinusoidal en bout de poutre
    % 3 Deplacement impose en milieu de poutre
    % 4 Effort continue en bout de poutre
    % 5 Effort augmentant lineairement en bout de poutre
    % 6 Effort continue en bout de poutre les premiers pas de temps
        %cas.T = 2e-4;
    % 7 Vitesse initiale
    % 8 Une periode de sinusverse
        %cas.T = 100*calcul.dt*2;%^iterCase; % 10*calcul.dt < T < Ttot/4  

w = warning ('off','all');
% w = warning ('on','all');

addpath('Afficher','POD','PGD','Matlab2Tikz')

clear all
clc

% diary FichierLog
% fileID = fopen('PGD.Conv.dat','w');
%     fprintf(fileID,'Creation \n');
%     fclose(fileID);


                        %% Creation du probleme %%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

calcul = ParamCalcul(4e-6   ,6     ,-1/3 );
        %ParamCalcul(dt     ,schem  ,alpha)
            % *dt *schem *alpha *nombreElements *CL

cas.type=4;
    cas.AmpliF=100;         % N 
    cas.T = 2e-4;

calcul.cas = cas;
problem = Poutre(calcul);
    % *M *C *K0 *Ttot *VectL *D *conditionU *conditionV *conditionA *HistF 
    % *U0 *V0 *nonLinearite *verif

                       %% Solution Complete %%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
method= struct('type',0); %struct('type',0,'Modes',[],'k',0,'m',0,'Apriori',[]);
method.type = 1;

SoluComplete = Resolution(calcul,problem,method);
    
                      %% Reduction du modele %%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

method= struct('type',0,'Modes',[],'Apriori',[]);
method.type = 2;
method.Modes = 1:30;%(size(M,1)-size(D,1));
method.Apriori = SoluComplete.f.HistU';

SoluPOD = Resolution(calcul,problem,method);

                             %% PGD %%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

method= struct('type',0,'k',[],'m',[]);
method.type = 3;
method.k = 30;        % Nombre d'iterations max pour obtenir un mode
method.m = 5;        % Nombre de modes maximum

SoluPGD = Resolution(calcul,problem,method);
            


%% Solution Exacte
   % Sans ressort - E constant - Cas 4, 5 et 6
    %[HistUExact,HistVExact,HistAExact] = SolutionExacte(calcul,problem);


%% Animation
    %AfficherAnimation(SoluComplete.f.HistV,SoluPGD,problem,calcul);



%% Affichage Complet POD

    Ref     = SoluComplete.f.HistU;
    MET     = [];   %ModesEspaceTemps
    ME      = [];   %ModesEspace
    MT      = [];   %ModesTemps
    Res     = 1:5; %Resultat
    NDR     = 0;    %NoDisplayResultat 
    NDE     = 0;    %NoDisplayErreur
    %titre = ['POD calcul.schem=' num2str(calcul.schem)];

    ErrPOD = AfficherMethode(Ref,SoluPGD,MET,ME,MT,Res,NDR,NDE);

   
return;
                        %% Analyse des modes %%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   
ModePOD = (SoluPOD( size(SoluPOD,2) ).p )';
NbModesPOD= size(ModePOD,1);
NbModesPGD = SoluPGD.method.m;
ModePGD=zeros(NbModesPGD,size(problem.VectL,2));

for i=1:NbModesPGD
    ModePGD(i,:) = SoluPGD.HistMf(1:size(problem.VectL,2),i)';
end

AnalyseDeMAC(NbModesPOD,NbModesPGD,ModePOD,ModePGD);


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


    



