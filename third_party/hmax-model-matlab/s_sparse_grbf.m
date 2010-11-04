%---------------------------------------------------------
%
%
%sharat@mit.edu
%---------------------------------------------------------
function [s] = s_sparse_exp_tuning(c,patches,sigma)
DEBUG            = 0;
num_bands        = length(c);
s                = cell(num_bands,1);
for b = 1:num_bands
  c_tmp          = c{b};
  [cht,cwt,cdir] = size(c_tmp);
  s{b}           = [];
  for p = 1:length(patches)
    patch                = patches{p};
    [pht,pwt,pdir]       = size(patch);
	pmsk                 = zeros(size(patch));
	pmsk(find(patch))    = 1;
    patch                = patch.*pmsk;
    res_tmp              = zeros(cht,cwt)+sum(patch(:).^2);
    for d     = 1:pdir
      img      = c_tmp(:,:,d);
      tmp      = imfilter(single(img),patch(:,:,d),'same');
	  img2     = imfilter(single(img.^2),pmsk(:,:,d),'same');
      res_tmp  = res_tmp+img2-2*tmp;
    end;
    res_tmp    = exp(-res_tmp/(2*sigma*sigma));
    off        = [floor(pht/2) floor(pwt/2)];
    sz         = [cht-pht+1 cwt-pwt+1];
    s{b}(:,:,p)=res_tmp(off(1)+[1:sz(1)],off(2)+[1:sz(2)]);
  end;
end;
%imagesc(tmp);pause(1);

