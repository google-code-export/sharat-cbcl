%---------------------------------------------------------
%s_norm_filter
% computes an S layer using normalized dot product
% takes as input layer C_{N-1}, and a set of filters to produce layer S_N
% parameters:
%     c      : [IN] a scale pyarmid, produced using create_c0 or from a
%              previous C layer.
%     patches: [IN]  set of filters
%     s      : [OUT] output scale pyramid
%sharat@mit.edu
%---------------------------------------------------------
function [s] = s_norm_filter(c,patches)
DEBUG            = 0;
num_bands        = length(c);
s                = cell(num_bands,1);
for b = 1:num_bands
  c_tmp          = c{b};
  [cht,cwt,cdir] = size(c_tmp);
  s{b}           = [];
  for p = 1:length(patches)
    patch            = patches{p};
    [pht,pwt,pdir]   = size(patch);
    res_tmp          = zeros(cht-pht+1,cwt-pwt+1);
    img2             = zeros(cht-pht+1,cwt-pwt+1);
    if(pht> cht | pwt>cwt) 
     continue;
    end;%patch larger than image!
    for d     = 1:pdir
      img      = c_tmp(:,:,d);
      img2     = img2+conv2(ones(pht,1),ones(pwt,1),img.^2,'valid'); 
      tmp      = conv2(c_tmp(:,:,d),patch(end:-1:1,end:-1:1,d),'valid');
      res_tmp  = res_tmp+tmp;
    end;
    res_tmp    = abs(res_tmp./sqrt(img2+ ~img2));
    res_tmp    = padarray(res_tmp,[floor((pht-1)/2),floor((pwt-1)/2)],'pre');
    res_tmp    = padarray(res_tmp,[ceil((pht-1)/2),ceil((pwt-1)/2)],'post');
    s{b}(:,:,p)= res_tmp;
  end;
end;


