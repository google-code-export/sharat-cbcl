%-----------------------------------
%
%-----------------------------------
function M = spdiag(x)
    N = length(x);
    M = sparse([1:N],[1:N],x);
%end function
