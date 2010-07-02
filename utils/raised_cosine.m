function w = raised_cosine(sz,OFF)
   w = ones(sz-2*OFF,1);
   x = (0:OFF-1)';
   wp= 0.5*(1+cos(pi*x/OFF));
   w = [flipud(wp);w;wp];
   w = w(1:sz);
%end function
