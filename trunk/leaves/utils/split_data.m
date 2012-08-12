%------------------------------------------------
%crossval
% generates a balanced split for cross validation
% usage:
% [cv_set,trn_set] = crossval(Y,folds)
% Y     - labels 
% folds - number of splits required
% cv_set,trn_set - cell array of indices
%sharat@mit.edu
%-----------------------------------------------
function [cv_set,trn_set] = split_data(Y,folds,RANDOMIZE)
Y         = Y(:)'; %conver to row vector
lbl       = unique(Y);
cv_set    = cell(folds,1);
trn_set   = cell(folds,1);
if(nargin<3)
  RANDOMIZE=1;
end;
rand('twister',sum(100*clock));
for l = 1:length(lbl)
  idx       = find(Y==lbl(l));
  ndata     = length(idx);
  if(RANDOMIZE)
    idx       = idx(randperm(length(idx)));
  end;
  N         = floor((ndata + folds -1)/folds);
  for i = 1:folds
    cv_set{i}  = [cv_set{i},idx((i-1)*N+1:min(i*N,end))];
    trn_set{i} = [trn_set{i},idx([1:(i-1)*N,i*N+1:end])];
  end;
end;
whos trn_set, cv_set,Y

