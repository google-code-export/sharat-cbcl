function model = BinaryClassifier(X,Y)
  model.p = mean(X(:,Y==1),2);
  model.q = mean(X(:,Y~=1),2);
%end function
