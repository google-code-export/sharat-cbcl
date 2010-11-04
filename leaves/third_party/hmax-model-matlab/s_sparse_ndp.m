%---------------------------------------------------------
%
%
%sharat@mit.edu
%---------------------------------------------------------
function [s] = s_sparse_ndp(c,patches,sigma)
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
	pnorm                = norm(patch(:));
    num_tmp              = zeros(cht,cwt);
	den_tmp              = zeros(cht,cwt);
    for d     = 1:pdir
      img      = c_tmp(:,:,d);
      tmp      = imfilter(single(img),patch(:,:,d),'same');
	  img2     = imfilter(single(img.^2),pmsk(:,:,d),'same');
      num_tmp  = num_tmp+tmp;
	  den_tmp  = den_tmp+img2;
    end;
    res_tmp    = num_tmp./(sqrt(den_tmp+eps)*pnorm+eps);
    s{b}(:,:,p)= res_tmp;
  end;
end;

