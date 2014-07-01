function [HistUExact,HistVExact,HistAExact] = SolutionExacte(calcul,problem)

    L = problem.L ;
    VectT = 0:calcul.dt:problem.Ttot ;
    c=(problem.Egene/problem.rho)^(0.5);
    
    HistAExact=zeros( size(problem.VectL,2),size(VectT,2) );
    HistVExact=zeros( size(problem.VectL,2),size(VectT,2) );
    HistUExact=zeros( size(problem.VectL,2),size(VectT,2) );
    
   if problem.kres || problem.nonLine || problem.ENonConstant
        HistAExact = [];
        HistVExact = [];
        HistUExact = [];
        return;
   end
        
   if calcul.cas.type == 4
        CoeffChoc = ((c*calcul.cas.AmpliF)/(problem.Egene*problem.Sec));
        for j=1:(size(VectT,2))
            for i=1:size(problem.VectL,2)
                x= problem.VectL(i);
                t= VectT(j);
                k= floor(c*t/(2*L));
                if (x > abs(L-c*t+2*k*L) )
                    HistVExact(i,j) = (-1)^k* CoeffChoc;
                end
                
                t2k = mod(t,4*L/c);
                if      (t2k > (  L-x)/c) && (t2k < (  L+x)/c)
                    HistUExact(i,j) = CoeffChoc * (t2k - (L-x)/c);
                elseif  (t2k > (  L+x)/c) && (t2k < (3*L-x)/c)
                    HistUExact(i,j) = CoeffChoc * 2*x/c;
                elseif  (t2k > (3*L-x)/c) && (t2k < (3*L+x)/c)
                    HistUExact(i,j) = CoeffChoc * ( 2*x/c - ( t2k - (3*L-x)/c ));
                end
                
                if (j>1)
                    HistAExact(i,j) = ( HistVExact(i,j) -HistVExact(i,j-1) ) / calcul.dt;
                end
            end
        end
    elseif calcul.cas.type == 6
        CoeffChoc = ((c*calcul.cas.AmpliF)/(problem.Egene*problem.Sec));
        for j=1:(size(VectT,2))
            for i=1:size(problem.VectL,2)
                x= problem.VectL(i);
                t= VectT(j);
                k= floor(c*t/(2*L));
                if (x > abs(L-c*t+2*k*L) )
                    HistVExact(i,j) = (-1)^k* CoeffChoc;
                end
                
                t2k = mod(t,4*L/c);
                if      (t2k > (  L-x)/c) && (t2k < (  L+x)/c)
                    HistUExact(i,j) = CoeffChoc * (t2k - (L-x)/c);
                elseif  (t2k > (  L+x)/c) && (t2k < (3*L-x)/c)
                    HistUExact(i,j) = CoeffChoc * 2*x/c;
                elseif  (t2k > (3*L-x)/c) && (t2k < (3*L+x)/c)
                    HistUExact(i,j) = CoeffChoc * ( 2*x/c - ( t2k - (3*L-x)/c ));
                end
                
            end
        end
        
        NbPas6 = round(calcul.cas.T/calcul.dt);
        for j=(NbPas6+1):(size(VectT,2))
            for i=1:size(problem.VectL,2)
                x= problem.VectL(i);
                t= VectT(j-NbPas6);
                k= floor(c*t/(2*L));
                if (x > abs(L-c*t+2*k*L) )
                    HistVExact(i,j) = HistVExact(i,j) - (-1)^k* CoeffChoc;
                end
                
                t2k = mod(t,4*L/c);
                if      (t2k > (  L-x)/c) && (t2k < (  L+x)/c)
                    HistUExact(i,j) = HistUExact(i,j) - CoeffChoc * (t2k - (L-x)/c);
                elseif  (t2k > (  L+x)/c) && (t2k < (3*L-x)/c)
                    HistUExact(i,j) = HistUExact(i,j) - CoeffChoc * 2*x/c;
                elseif  (t2k > (3*L-x)/c) && (t2k < (3*L+x)/c)
                    HistUExact(i,j) = HistUExact(i,j) - CoeffChoc * ( 2*x/c - ( t2k - (3*L-x)/c ));
                end
                
            end
        end
        
        for j=2:(size(VectT,2))
            for i=1:size(problem.VectL,2)
                HistAExact(i,j) = ( HistVExact(i,j) -HistVExact(i,j-1) ) / calcul.dt;
            end
        end
        
    elseif calcul.cas.type == 5
        % Dans ce cas AmpliF est utilise comme coefficient de la rampe,
        %  donc dans la bonne unite pour (c*AmpliF)/(Egene*Sec) soit une
        %  acceleration
        CoeffChoc = ((c*calcul.cas.AmpliF)/(problem.Egene*problem.Sec));
        for j=1:(size(VectT,2))
            for i=1:size(problem.VectL,2)
                x= problem.VectL(i);
                t= VectT(j);
                k= floor(c*t/(2*L));
                Dk = floor(k/2);
                if (x > abs(L-c*t+2*k*L) )
                    HistAExact(i,j) = (-1)^k* CoeffChoc;
                end
                
                t2k = mod(t,4*L/c);
                if      (t2k > (  L-x)/c) && (t2k < (  L+x)/c)
                    HistVExact(i,j) = CoeffChoc* (t2k - (L-x)/c);
                elseif  (t2k > (  L+x)/c) && (t2k < (3*L-x)/c)
                    HistVExact(i,j) = CoeffChoc* 2*x/c;
                elseif  (t2k > (3*L-x)/c) && (t2k < (3*L+x)/c)
                    HistVExact(i,j) = CoeffChoc* ( 2*x/c - ( t2k - (3*L-x)/c ));
                end
                
                CycleU = Dk * CoeffChoc * 2*x * 2*L/(c^2);
                if  (t2k < (2*L/c) )
                    if      (t2k > (L-x)/c ) && (t2k < (L+x)/c )
                        HistUExact(i,j) = CycleU + CoeffChoc* 1/2*(t2k- (L-x)/c)^2;
                    elseif  (t2k > (L+x)/c )
                        HistUExact(i,j) = CycleU + CoeffChoc* ( (2*x^2)/c^2 + (2*x/c)*(t2k - (L+x)/c) );
                    else
                        HistUExact(i,j) = CycleU ;
                    end
                else                    
                    if (t2k > (3*L-x)/c ) && (t2k < (3*L+x)/c )
                        HistUExact(i,j) = CycleU + CoeffChoc* ( (2*x^2)/c^2 + (2*x/c)*(t2k - (L+x)/c) );
                        HistUExact(i,j) = HistUExact(i,j) - CoeffChoc* 1/2*(t2k- (3*L-x)/c)^2;
                    elseif (t2k > (3*L+x)/c )
                        HistUExact(i,j) = CycleU + CoeffChoc*2*x * 2*L/(c^2);
                    else
                        HistUExact(i,j) = CycleU + CoeffChoc* ( (2*x^2)/c^2 + (2*x/c)*(t2k - (L+x)/c) );
                    end
                end
                
            end
        end
    else
        HistAExact = [];
        HistVExact = [];
        HistUExact = [];
    end