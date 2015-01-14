function [result] = ButeeParPartie(J,dJ,k,x,y)

    result= ((k*dJ^2)/(((x'*y)-J)-dJ) + k*(J-dJ)); 

end