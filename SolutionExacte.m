function [HistUExact,HistVExact,HistAExact] = SolutionExacte(problem)

    calcul = problem.calcul;
    L = problem.L ;
    VectT = 0:calcul.dt:calcul.Ttot ;
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
        if ( (calcul.cas.T-NbPas6*calcul.dt) ~= 0)
            disp('cas.T n est pas un multiple de dt')
        end
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
        %  donc dans la bonne unite pour que (c*AmpliF)/(Egene*Sec) soit
        %  une acceleration
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
%     elseif calcul.cas.type == 2
%         
%         Tau = problem.calcul.cas.T;
%         t   = VectT;
%         x   = problem.VectL;
% 
%         U=0*t;
%         N=[];
%         for j=0:50
% 
%             wj=(2*j+1)*pi*c/(2*L);
%             q = ((-1)^(j+1))*( (1/(wj^2-(2*pi/Tau)^2) - 1/(wj^2))*cos(wj*t) - (1/(wj^2-(2*pi/Tau)^2))*cos(2*pi*t/Tau) + 1/wj^2  );
%             u = sin(((2*j+1)/2)*pi*x/L); % x/L = 1
%             U1=q*u;
%             
%             U  =  U + U1;
%             N= [N max(U1)-min(U1)];
%         end
%         
%         HistUExact = cas.AmpliF * 2/(rho*S*L) * U;
    elseif (calcul.cas.type == 8 || calcul.cas.type == 2)
        
        Tau = problem.calcul.cas.T;
        %Tau = (4/9) * L/c;
        cas = calcul.cas.type;
        if cas == 8
            NbPas = round(Tau/calcul.dt);
            if ( (Tau-NbPas*calcul.dt) ~= 0)
                disp('cas.T n est pas un multiple de dt')
            end
            if (size(VectT,2)>(NbPas+1))
                t1  = VectT(1:(NbPas+1));
                t2  = VectT((NbPas+2):end);
            else
                cas = 2;
            end
        end
        if cas == 2
            t1 = VectT;
            t2 = [];
            U2 = [];
        end
        x   = problem.VectL';
        
        nMax=5000;
        
        U=0*(x*VectT);
        
        for j=0:nMax

            wj=(2*j+1)*pi*c/(2*L);
            q1 = ((-1)^(j+1))*( (1/(wj^2-(2*pi/Tau)^2) - 1/(wj^2))*cos(wj*t1) - (1/(wj^2-(2*pi/Tau)^2))*cos(2*pi*t1/Tau) + 1/wj^2  );
            u = sin(((2*j+1)/2)*pi*x/L);
            U1=u*q1;
            
            
            if size(t2,2)
                q2 = ((-1)^(j+1))*( (1/(wj^2-(2*pi/Tau)^2) - 1/(wj^2))*(cos(wj*t2) - cos(wj*(t2-Tau))) );
                U2=u*q2;
            end
            
            
            U0 = [U1 U2];
            U  =  U + U0;
        end
        HistUExact = -calcul.cas.AmpliF * 2/(problem.rho * problem.Sec *L) * U;
        HistUExact(end,:)=0;
    
        
    elseif calcul.cas.type == 32424 %LOUF
       
       % Demi periode de sinus
        % n=100;
        % CoeffChoc = ((2*calcul.cas.AmpliF)/(problem.rho*problem.Sec*L));
        % T=calcul.cas.T;  % tau
        % tT=floor(T/calcul.dt);
        % for i = 1:n
        %     B= ((2*i-1)*pi)/(2*L);   % beta(n)
        %     w= B*c;                          % omega(n)
        %     HistUExact(:,1:tT)=-HistUExact(:,1:tT)+ (( ((-1)^(n+1))/(w^2-(pi/T)^2) ) * ( sin(pi*VectT(1:tT)'/T) - (pi/(T*w))*sin(w*VectT(1:tT)') )*sin(B*problem.VectL))';
        %     HistUExact(:,(tT+1):end)=-HistUExact(:,(tT+1):end)+ (( ((-1)^(n+1))/(w^2-(pi/T)^2) ) *(pi/(T*w))* ( sin(w*(T-VectT((tT+1):end)')) - sin(w*VectT((tT+1):end)') )*sin(B*problem.VectL))';
        % end
        % HistUExact = HistUExact * CoeffChoc;
       
       % Echelon
        % n=100;
        % CoeffChoc = ((2*calcul.cas.AmpliF)/(problem.rho*problem.Sec*L));
        % for i = 1:n
        %     B= ((2*i-1)*pi)/(2*L);   % beta(n)
        %     w= B*c;                          % omega(n)
        %     HistUExact=-HistUExact+ (( ((-1)^(n+1))/(w^2) ) * ( 1 - cos(w*VectT') )*sin(B*problem.VectL))';
        % end
        % HistUExact = HistUExact * CoeffChoc;
       
    else
        HistAExact = [];
        HistVExact = [];
        HistUExact = [];
    end