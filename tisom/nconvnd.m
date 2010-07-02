%---------------------------------------------------------
%
%
%sharat@mit.edu
%---------------------------------------------------------
function out = convnd(c,patch)
    [cht,cwt,cdir]   = size(c);
    [pht,pwt,pdir]   = size(patch);
    ptch2            = sum(patch(:).^2);
    img2             = conv2(ones(pht,1),ones(pwt,1),sum(c.^2,3),'valid');
    res_tmp          = zeros(cht-pht+1,cwt-pwt+1,pdir);
    for d     = 1:pdir
      img      = single(c(:,:,d));
      tmp      = conv2(img,patch(end:-1:1,end:-1:1,d),'valid');
      res_tmp  = res_tmp+tmp;
    end;
    res_tmp    = res_tmp./sqrt(img2+0.01);
    %res_tmp    = padarray(res_tmp,[floor((pht-1)/2),floor((pwt-1)/2)],'pre');
    %res_tmp    = padarray(res_tmp,[ceil((pht-1)/2),ceil((pwt-1)/2)],'post');
    out        = res_tmp;
