function [labels,weights,firstindeces] = CLSchi2C(X,Model);


if isfield(Model,'deg')
  deg = Model.deg;
else 
  deg = 2;
end

len1 = size(X,2);
len2 = size(Model.trainX,2);

distance = zeros(len2,len1);
for i = 1:len1,
    for j = 1:len2,
        A             = (X(:,i)+Model.trainX(:,j));
        A             = (A>0).*A + (A==0);
        distance(j,i) = sum( (abs(X(:,i)-Model.trainX(:,j)).^deg) ./ A );
    end
end

[sorted,index] = sort(distance);
yy = Model.trainy(index);
if Model.k>1
  weights = mean(yy(1:Model.k,:),1)';
  disp('kNN weights::just sign no voting');
  labels = sign(weights);
else
  labels = yy(1,:)';
  weights = 1./(sorted(1,:)'+eps);
end

if nargout>2
  numindeces = min(size(sorted,1),Model.numindeces);
  firstindeces = yy(1:numindeces,:)';
end

