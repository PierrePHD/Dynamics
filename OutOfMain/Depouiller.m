
Tstep = [ 400 200 100 50 25 10 5 ]; %e-8
Cas = [ 2 8 ];
Schem = [ 3 4 5 ];
Tcharge = [ 40 60 80 120 160 200 250 ]; %e-6

NbIter= size(Tstep,2)*size(Cas,2)*size(Schem,2)*size(Tcharge,2);

Result= struct('tstep',0,'cas',0,'schem',0,'tcharge',0,'ErreurPGD',[]);

iter =0;
for tstep = Tstep
    tstep
    
    for cas = Cas
        
        for schem = Schem

            for tcharge = Tcharge
                iter = iter+1;
                %JOB_cas_${cas}_schem_${schem}_Tcharge_${Tcharge}_Tstep_${Tstep}/
                %Res_cas_${cas}_schem_${schem}_Tcharge_${Tcharge}_Tstep_${Tstep}.mat
                specific = ['cas_' num2str(cas) '_schem_' num2str(schem) '_Tcharge_' num2str(tcharge) '_Tstep_' num2str(tstep)];
                Fichier = ['JOB_' specific '/Res_' specific '.mat'];
                Result.tstep =tstep;
                Result.cas =cas;
                Result.schem =schem;
                Result.tcharge =tcharge;
                load(Fichier, 'ErrPGD');
                Result.ErreurPGD = ErrPGD;
                Results(iter) =Result;
            end
        end
    end
end

save('Depouillement','Results','Tstep','Cas','Schem','Tcharge');


return ;

%% Lecture

clear all
load('Depouillement')

NbIter = size(Tstep,2);
IterJump = size(Cas,2)*size(Schem,2)*size(Tcharge,2);

for i = 1:NbIter;
    iter = 1 + IterJump * (i-1);
    if (i==1) couleur='r';
    elseif (i==2) couleur='g';
    elseif (i==3) couleur='b';
    elseif (i==4) couleur='k';
    elseif (i==5) couleur='r--';
    elseif (i==6) couleur='g--';
    elseif (i==7) couleur='b--';
    end
    plot(log(Results(iter).ErreurPGD.Maximale)/log(10),couleur)
    hold on;
end

saveas(gcf, ['Images/Sortie/mat' OutImage.titre 'Erreur.eps'], 'eps2c');