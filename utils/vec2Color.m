function out=vec2Color(vimg)
  [ht,wt,dim]=size(vimg);
  out        =zeros(ht,wt,3);
  for d=1:dim
    temp       = zeros(ht,wt,3);
    temp(:,:,1)= (d-1)/min(dim,4);
    temp(:,:,2)= 1;
    plane      = squeeze(vimg(:,:,d));
    temp(:,:,3)= imscale(plane);
    out        = out+hsv2rgb(temp);
  end;
  mx = max(out(:));
  mn = min(out(:));
  out= min(1,max(0,(out-mn)/(mx-mn)));
%end function
