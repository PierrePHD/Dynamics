function [calcul] = ParamCalcul(dt,schem,alpha)

calcul = struct('dt',0,'schem',0,'alpha',0,'CL',0);

    % *dt *schem(type, alpha) *nombreElements *CLmethod
    
    % dt
        %dt=  4e-6;%*2^-program ; %*0.5^program;

    % schema d integration :
        % 1 Newmark - Difference centree
        % 2 Newmark - Acceleration lineaire
        % 3 Newmark - Acceleration moyenne
        % 4 Newmark - Acceleration moyenne modifiee
        % 5 HHT-alpha
        % 6 Galerkin Discontinu
        % alpha : -1/3 <= alpha <= 0 
        
    % elements
        nombreElementsParPartie=80; %5  *2^program;
        nombrePartie=2  ;
        nombreElements = nombrePartie*nombreElementsParPartie; 
            %disp(['nombreElementsParPartie = ' num2str(nombreElementsParPartie)]);
        
    % Application des conditions limites :
        CL=1;
            %disp(['CL = ' num2str(CL)]);
        % 1 Multiplicateur de Lagrange
        % 2 Substitution
        
%         if (schem==6)
%             CL=2;
%         end
        
    calcul.dt   =dt;
    calcul.schem=schem;
    calcul.alpha=alpha;
    calcul.nombreElements=nombreElements;
    calcul.CL   =CL;
end