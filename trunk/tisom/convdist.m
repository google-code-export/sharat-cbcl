%---------------------------------------------------------
%
%
%sharat@mit.edu
%---------------------------------------------------------
function out = convdist(c,patch,SIGMA)
    if(nargin<3) SIGMA=1;end;
    [cht,cwt,cdir]   = size(c);
    [pht,pwt,pdir]   = size(patch);
    ptch2            = sum(patch(:).^2);
    img2             = conv2(ones(pht,1),ones(pwt,1),sum(c.^2,3),'valid');
    res_tmp          = img2+ptch2;
    for d     = 1:pdir
      img      = single(c(:,:,d));
      tmp      = conv2(img,patch(end:-1:1,end:-1:1,d),'valid');
      res_tmp  = res_tmp-2*tmp;
    end;
    res_tmp    = exp(-res_tmp);
    %res_tmp    = padarray(res_tmp,[floor((pht-1)/2),floor((pwt-1)/2)],'pre');
    %res_tmp    = padarray(res_tmp,[ceil((pht-1)/2),ceil((pwt-1)/2)],'post');
    out        = res_tmp;

