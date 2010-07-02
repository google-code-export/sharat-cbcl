%----------------------------------------------------------------------------------%
%
%sharat@mit.edu
%-----------------------------------------------------------------------------------
function res = area_filter(img,sz)
  [ht,wt] = size(img);
  pdl = ceil(sz/2); 
  pdr = sz-pdl;
  img = padarray(img,[pdl pdl],'pre','replicate');
  img = padarray(img,[pdr pdr],'post','replicate');
  img = cumsum(cumsum(img,1),2);
  res = zeros(size(img));
  for i = pdl+1:pdl+ht
    for j=pdl+1:pdl+wt
      res(i,j) = img(i-pdl,j-pdl)+img(i+pdr-1,j+pdr-1) - ...
	         img(i-pdl,j+pdr-1)- img(i+pdr-1,j-pdl);
    end;
  end;
  res = res(pdl+1:pdl+ht,pdl+1:pdl+wt);
%end function
