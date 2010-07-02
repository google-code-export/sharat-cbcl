%--------------------------------------------------------------------------
% computes the entropy of the data given that it contains the
% symbols given
% usage:
%  etp  = entropy(data,symbols)
%  data - (IN)  array containing discrete data (1XN)
%  sym  - (IN)  array containing the symbols in the data
%  etp  - (OUT) entropy in bits
% sharat@mit.edu
%--------------------------------------------------------------------------
function etp = entropy(data,sym)  
    N     = length(data);
    etp   = 0;
    for i = 1:length(sym)
       p    = sum(data==sym(i))/N;
       etp  = etp - p*log2(p+eps);
    end;
    etp = max(0,etp); %for 0 entropy  
%end function entropy

