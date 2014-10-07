function [HistMg,f_q,g_q,epsilon] = OrthoPGD(HistMf,HistMg,m,mMin,f_q,g_q)

    normOrigin = norm(f_q);
    SomProd=0;
    Somf_q =zeros(size(f_q));
    
    %verification de l ortogonalite des precedants modes
    for i= (mMin+1):(m-1)
        for j= (i+1):(m-1)
            ortho=HistMf(:,i)'*HistMf(:,j) / (norm(HistMf(:,i))*norm(HistMf(:,j)));
            disp(['Verif: i =' num2str(i) ' j =' num2str(j) ' prod = ' num2str(ortho)]);
            if ortho > 1e-12
                stopppp
            end
        end
    end
            
    HistVerif = g_q.u(:)*(f_q');
    for k=1:(m-1)
            g=HistMg(k).u(:);
            HistVerif = HistVerif + g*(HistMf(:,k)') ;
    end
    
    figure('Name',['Mode ET avant Ortho avec '  num2str(m) ' modes'],'NumberTitle','off');
        for k=1:(m-1)
            subplot(ceil(sqrt(m)),ceil(m/ceil(sqrt(m))),k);
            
            g=HistMg(k).u(:);
            Hist =  g*(HistMf(:,k)') ;
            ampli = max(Hist(:)) - min(Hist(:));
            zoom = -floor(log(ampli)/log(10)) ;
            surf(Hist'*(10^zoom),'EdgeColor','none');
            zlabel(['u(x,t)*10^' num2str(zoom) ]);
        end
        subplot(ceil(sqrt(m)),ceil(m/ceil(sqrt(m))),m);
        g=g_q.u(:);
        Hist =  g*(f_q') ;
        ampli = max(Hist(:)) - min(Hist(:));
        zoom = -floor(log(ampli)/log(10));
        surf(Hist'*(10^zoom),'EdgeColor','none');
        zlabel(['u(x,t)*10^' num2str(zoom) ]);
        
    for i= (mMin+1):(m-1)
        prod = HistMf(:,i)'*f_q / norm(HistMf(:,i)); % division inutile si norm(f)=1
            disp(['Verif: i =' num2str(i) ' f_q(' num2str(m) ') prod = ' num2str(prod)]);
        %if prod > 0.1
            HistMg(:,i).u=HistMg(:,i).u + prod* g_q.u ;
            HistMg(:,i).v=HistMg(:,i).v + prod* g_q.v ;
            HistMg(:,i).w=HistMg(:,i).u + prod* g_q.w ;
        %end
        
%         figure;
%         for k=1:(m-1)
%             subplot(ceil(sqrt(m)),ceil(m/ceil(sqrt(m))),k);
%             plot(HistMf(:,k));
%         end
%         subplot(ceil(sqrt(m)),ceil(m/ceil(sqrt(m))),m);
%         plot(f_q);
%         figure;
        
        
        figure('Name',['Modes ET i='  num2str(i) ],'NumberTitle','off');
        for k=1:(m-1)
            subplot(ceil(sqrt(m)),ceil(m/ceil(sqrt(m))),k);
            
            g=HistMg(k).u(:);
            Hist =  g*(HistMf(:,k)') ;
            ampli = max(Hist(:)) - min(Hist(:));
            zoom = -floor(log(ampli)/log(10)) ;
            surf(Hist'*(10^zoom),'EdgeColor','none');
            zlabel(['u(x,t)*10^' num2str(zoom) ]);
        end
        subplot(ceil(sqrt(m)),ceil(m/ceil(sqrt(m))),m);
        g=g_q.u(:);
        Hist =  g*(f_q') ;
        ampli = max(Hist(:)) - min(Hist(:));
        zoom = -floor(log(ampli)/log(10));
        surf(Hist'*(10^zoom),'EdgeColor','none');
        zlabel(['u(x,t)*10^' num2str(zoom) ]);
        
        HistVerif2 = g_q.u(:)*(f_q');
        for k=1:(m-1)
                g=HistMg(k).u(:);
                HistVerif2 = HistVerif2 + g*(HistMf(:,k)') ;
        end
        AfficherSolution(HistVerif',HistVerif2',['VerifTotal i='  num2str(i) ],0:4.0e-06:1.0e-03,1:size(f_q,1),0);
        
        
        Somf_q = Somf_q +prod*HistMf(:,i);
        f_q = f_q - prod*HistMf(:,i);
        SomProd = SomProd + prod;
    end
    %f_q = f_q - Somf_q;
    
     HistVerif2 = g_q.u(:)*(f_q');
        for k=1:(m-1)
                g=HistMg(k).u(:);
                HistVerif2 = HistVerif2 + g*(HistMf(:,k)') ;
        end
        AfficherSolution(HistVerif',HistVerif2','VerifTotal Finale',0:4.0e-06:1.0e-03,1:size(f_q,1),0);
        
     
    normAfter=norm(f_q);
    epsilon = normAfter/normOrigin
    f_q = f_q/normAfter;
    g_q.u=g_q.u*normAfter;
    g_q.v=g_q.v*normAfter;
    g_q.w=g_q.w*normAfter;
end


%SizeVectL=size(problem.VectL,2)
%SoluPGD.HistMf(:,1)'*SoluPGD.HistMf(:,2)