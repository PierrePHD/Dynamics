function [integrale] = IntegrLine(g1,g2,t0,dt)

    % Conditions :
        % g1 et g2 de meme taille
        % g1(n) = la valeur de la fonction g en t0+(n-1)*dt idem pour g2
        
    % on integre comme si les deux fonctions etaient lineaires entre les
    % point de valeur connues :
    % integrale de t1 a t2 du produit : (a*x+b)*(e*x+f) dt
    
    if (isa(g1,'numeric') )
       g1.m=g1;
       g1.p=g1.m;
    end
    if (isa(g2,'numeric') )
       g2.m=g2;
       g2.p=g2.m;        
    end
    
    if ( ~min( size(g1.m)==size(g2.m) ))
        if ( ~min( size((g1.m)')==size(g2.m) ))
            disp('Erreur dans IntegrLine.m les deux vecteur n ont pas la meme taille');
            disp('La taille de g1 est');
            size(g1.m)
            disp('La taille de g2 est');
            size(g2.m)
            Error;            
        else
           g1.m=(g1.m)';
           g1.p=(g1.p)';
        end
    end
    
    integrale = 0;
    for n=1:(max(size(g1.m))-1)    
        % Integrale de t1 a t2
        t1 = t0 + (n-1)*dt;
        t2 = t0 +    n *dt;
        a= ( g1.m(n+1) - g1.p(n) )/dt;  %( g1(t2) - g1(t1) )/dt; 
        b= g1.p(n) - a*t1 ; 
        e= ( g2.m(n+1) - g2.p(n) )/dt;
        f= g2.p(n) - e*t2 ; 

        integrale = integrale + (a*e/3)*(t2^3 - t1^3) + (a*f+b*e)*(t2^2 - t1^2) + b*f*(t2-t1);
    end
    
end