function d = euclid_dist(data,ftr)
  [D,N] = size(data);
  d     = (data-repmat(ftr,1,N)).^2;
  d     = sqrt(sum(d));
%end function 
