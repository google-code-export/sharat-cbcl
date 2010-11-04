%---------------------------------------------------------
%s_grbf
%computes and S layer output using gaussian radial basis function
%parameters:
%    c       : [IN] scaled pyramid obtained from create_c0 or from previous C
%              layer
%    patches : [IN] prototypes
%    sigma   : [IN] determines how sparse the output S map is. Smaller
%              values lead to sparser maps.
%    s       : [OUT] output scale pyramid.
%sharat@mit.edu
%---------------------------------------------------------
function [s] = s_grbf(c,patches,sigma)
DEBUG            = 0;
num_bands        = length(c);
s                = cell(num_bands,1);
if(nargin<3)
  for p=1:length(patches)
	sigma(p)=norm(patches{p}(:))/sqrt(6);
  end;
end;

if(isscalar(sigma))
    sigma        = sigma*ones(length(patches),1);
end;

try
for b = 1:num_bands
  c_tmp          = c{b};
  [cht,cwt,cdir] = size(c_tmp);
  s{b}           = [];
  for p = 1:length(patches)
    patch            = patches{p};
    [pht,pwt,pdir]   = size(patch);
    %if(pht>= cht | pwt>=cwt) 
    % s{b}=zeros(1,1,cdir);
    % continue;
    %end;%patch larger than image!
    ptch2            = sum(patch(:).^2);
    img2             = conv2(ones(pht,1),ones(pwt,1),sum(c_tmp.^2,3),'valid');
    res_tmp          = img2+ptch2;
    for d     = 1:pdir
      img      = single(c_tmp(:,:,d));
      tmp      = conv2(img,patch(end:-1:1,end:-1:1,d),'valid');
      res_tmp  = res_tmp-2*tmp;
    end;
    res_tmp    = exp(-res_tmp/(2*sigma(p)*sigma(p)));
    res_tmp    = padarray(res_tmp,[floor((pht-1)/2),floor((pwt-1)/2)],'pre');
    res_tmp    = padarray(res_tmp,[ceil((pht-1)/2),ceil((pwt-1)/2)],'post');
    s{b}(:,:,p)= res_tmp;
  end;%p
end;
catch
  err=lasterror;
  keyboard;
end;
