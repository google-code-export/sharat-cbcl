%--------------------------------------------------
%
%
%--------------------------------------------------
function patch_pca = find_pca(patches,tol)
  num_sizes   = length(patches);
  num_patches = length(patches{1});
  for i=1:num_sizes
    X=[];
    for j=1:num_patches
      tmp_patch = patches{i}{j};
      tmp_patch = tmp_patch(:)';    %conver to a row
      X         = [X;tmp_patch]; %each row is a patch
    end;
    [pca,pcaw]       = do_pca(X,tol);
    patch_pca.patches= patches;
    patch_pca.pca{i} = pca;
    patch_pca.pcaw{i}= pcaw;
    patch_pca.mean{i}= mean(X);
  end;
%end function 

%------------------------------------
%
% pcaw = eigen vectors (each column is a vector)
% pca  = eigen projections (each colum in a projection)
%------------------------------------
function [pca,pcaw] = do_pca(x,tol)
   [n,d]= size(x);
   mx   = mean(x);
   K    = cov(x);
   [V,D]= eig(K);
   D    = diag(D).^2; D=D(end:-1:1);
   V    = V(:,end:-1:1);
   D    = cumsum(D/sum(D));
   k    = find(D>= 1-tol);
   k    = k(1);
   pcaw = V(:,1:k);
   pca  = (x*pcaw)';
%end function
