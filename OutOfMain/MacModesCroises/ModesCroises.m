% ModesCroises
close all
clear all


%     Ref     = SoluComplete.f.HistU;
%     MET     = [];   %ModesEspaceTemps
%     ME      = [];   %ModesEspace
%     MT      = [];   %ModesTemps
%     Res     = [];   %Resultat
%     NDR     = 1;    %NoDisplayResultat 
%     NDE     = 0;    %NoDisplayErreur
%     OI      = struct('MET',0,'ME',0,'MT',0,'Res',0,'Err',0,'titre',''); %OutImage
%     %titre = ['POD calcul.schem=' num2str(calcul.schem)];
%     
%         
%         OI.titre = 'PGD';
%         Res     = 1:SoluPGD.Mmax; %Resultat   
%         ErrPGD = AfficherMethode(Ref,SoluPGD,MET,ME,MT,Res,NDR,NDE,OI);
        
        
                        %% Analyse des modes %%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
load('OutCas8schem3.mat','SoluPGD','problem','SoluPOD');

for j = [1 3 2]
    
    NbModes1PGD = 39; %SoluPGD.Mmax;
        
    if (j==1 || j==2)
        Mode1PGD=zeros(NbModes1PGD,size(problem.VectL,2));
        ModesRedrese=zeros(NbModes1PGD,size(problem.VectL,2));
        if j==1
            titre1 = 'SVD(PGD)';
        elseif j==2
            titre1 = 'SVD(PGD Ponderee)';
        end

        for i=1:NbModes1PGD
            if (j==1)
                ponderer(i) = norm(SoluPGD.HistMg(1).u(:));
            else
                ponderer(i) = norm(SoluPGD.HistMg(i).u(:));
            end
            Mode1PGD(i,:) = SoluPGD.HistMf(:,i)' *ponderer(i); 
        end
        
    else
        
        titre1 = 'SVD(SoluPGD)';
        ModesRedrese = zeros(NbModes1PGD,size(problem.VectL,2));
        ResultatSol  = zeros(size(problem.VectL,2),size(0:problem.calcul.dt:problem.calcul.Ttot,2));
        %f=HistMf(:,1:n);
        for l=1:NbModes1PGD
            %g=HistMg(l).u(:);
            ResultatSol = ResultatSol +   (SoluPGD.HistMg(l).u(:)*(SoluPGD.HistMf(:,l)'))'; %f(j,l)*g(k)
        end
        Mode1PGD = ResultatSol';
    end


[U_SVD,S_SVD,V_SVD]=svd(Mode1PGD);   %svd(Mode1PGD); 
[S]=svd(Mode1PGD); 
%figure('Name',['SVal: ' titre1],'NumberTitle','off')

            if j==1
                ccc = 'red';
            elseif j==2
                ccc = 'blue';
            elseif j==3
                ccc = 'green';
            end
plot(log(S(1:29))/log(10),'LineWidth',2,'color',ccc);
%legend('PGD Modes','PGD Solution','Weighted PGD')
hold on;
%saveas(gcf, ['Images/Sortie/matValeursSinguliere' titre1 '.eps'], 'eps2c');
%plot(log(ponderer)/log(10),'LineWidth',2);

for i=1:NbModes1PGD
ModesRedrese(i,:) =V_SVD(:,i)';

end

% if j==2
%     titre2='SVD(PGD Ponderee)';
%     ModePOD = ModesRedrese;
%     NbModesPOD = NbModes1PGD
% end

titre2= 'POD';
ModePOD = (SoluPOD( size(SoluPOD,2) ).p )';
 NbModesPOD= size(ModePOD,1);

NbModes2PGD = SoluPGD.Mmax;
Mode2PGD=zeros(NbModes2PGD,size(problem.VectL,2));

for i=1:NbModes2PGD
    Mode2PGD(i,:) = SoluPGD.HistMf(:,i)';  %SoluPGD.HistMf(1:size(problem.VectL,2),i)';
end

%AnalyseDeMAC(29,29,ModesRedrese,ModePOD,2,0,titre1,titre2);

end

%exit
