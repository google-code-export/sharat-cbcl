%------------------------------------------------------------------------
%
%
%
%sharat@mit.edu
%-----------------------------------------------------------------------
function y = multiclass_svm_test(X,Model)
  [N,N] = size(Model);
  Cij   = zeros(N*(N-1)/2,size(X,2));
  idx   = 1;
  %------------------------------------------
  %
  %------------------------------------------
  for i = 1:N
    for j = i+1:N
      tmp_y            = CLSosusvmC(X,Model{i,j});
      Cij(idx,tmp_y>0) = i;
      Cij(idx,tmp_y<=0)= j;
      idx              = idx+1;
    end;
  end;
  %------------------------------------------
  %get the counts
  %------------------------------------------
  for i = 1:size(X,2)
    [n,x]   =  hist(Cij(:,i),1:N);
    [n,idx] =  sort(n,'descend');
    y(i)    =  x(idx(1));
  end;
%end function
