%--------------------------------------------
%cmim
% computes conditional mutual information
% between a pair of variables
%--------------------------------------------
function mi = cmim(posx,negx,posy,negy)
    cpos = [2*posx+posy]; %joint feature
    cneg = [2*negx+negy];
    %compute diff entropy
    hx    = entropy([cpos,cneg],[0:3]);
    p0    = length(cneg)/(length(cpos)+length(cneg));
    p1    = 1-p0;
    hx_0  = entropy(cneg,[0:3]);
    hx_1  = entropy(cpos,[0:3]);
    mi    = hx-(p0*hx_0+p1*hx_1);
%end function cmim
