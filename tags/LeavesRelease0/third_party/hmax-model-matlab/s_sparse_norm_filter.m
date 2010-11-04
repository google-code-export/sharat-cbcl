%---------------------------------------------------------
%
%
%sharat@mit.edu
%---------------------------------------------------------
function [s] = s_generic_sparse_norm_filter(c,patches)
DEBUG            = 0;
num_bands        = length(c);
s                = cell(num_bands,1);
for b = 1:num_bands
  c_tmp          = c{b};
  [cht,cwt,cdir] = size(c_tmp);
  s{b}           = zeros(cht,cwt,length(patches));
  for p = 1:length(patches)
    patch               = patches{p};
    [pht,pwt,pdir]      = size(patch);
	pmsk                = zeros(size(patch));
	pmsk(find(patch))   = 1;
    patch               = patch.*pmsk;
    ptch2               = sum(patch(:).^2);
    res_tmp             = zeros(cht,cwt);
    img2                = zeros(cht,cwt);
    for d     = 1:pdir
      img      = c_tmp(:,:,d);
      res_tmp  = res_tmp+conv2(img,patch(end:-1:1,end:-1:1,d),'same');
      img2     = img2+conv2(img.^2,pmsk(end:-1:1,end:-1:1,d),'same');
    end;
    res_tmp    = res_tmp;%./(sqrt(img2*ptch2+eps));
    s{b}(:,:,p)= res_tmp;
  end;
end;
%imagesc(tmp);pause(1);
