function [HistMg,f_q,g_q,epsilon] = Ortho2PGD(HistMf,HistMg,m,mMin,f_q,g_q,SizeVectL)

    normOrigin = norm(f_q(1:SizeVectL));
    %Somf_q =zeros(size(f_q));
        
    for i= (mMin+1):(m-1)
        prod = HistMf(1:SizeVectL,i)'*f_q(1:SizeVectL); % norm(f)=1 indispensable
       
            HistMg(:,i).u=HistMg(:,i).u + prod* g_q.u ;
            HistMg(:,i).v=HistMg(:,i).v + prod* g_q.v ;
            HistMg(:,i).w=HistMg(:,i).u + prod* g_q.w ;
        
        %Somf_q = Somf_q +prod*HistMf(:,i);
        f_q = f_q - prod*HistMf(:,i);
    end
    %f_q = f_q - Somf_q;
    normAfter=norm(f_q(1:SizeVectL));
    epsilon = normAfter/normOrigin;
    f_q = f_q/normAfter;
    g_q.u=g_q.u*normAfter;
    g_q.v=g_q.v*normAfter;
    g_q.w=g_q.w*normAfter;
end