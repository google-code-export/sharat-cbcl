%normalizes each column 
%
function X=normalize_l2(X)
    for i=1:size(X,2)
        X(:,i)=X(:,i)/norm(X(:,i));
    end;    
%end function
