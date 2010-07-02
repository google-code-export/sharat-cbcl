function d = l1_dist(data,ftr)
  [M,N] = size(data);
  d     = data-repmat(ftr,1,N);
  d     = sum(abs(d));
%end function 
