function d = log_euclid_dist(data,ftr)
  [D,N] = size(data);
  data  = log(data);
  ftr   = log(ftr);
  d     = (data-repmat(ftr,1,N)).^2;
  d     = sqrt(sum(d));
%end function 
