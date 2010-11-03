function [Model,looerrors] = CLSchi2(X,y,sPARAMS);

if nargin<3
  sPARAMS.k = 1;
end

if ~isfield(sPARAMS,'deg')
  sPARAMS.deg = 2;
end

Model.k      = sPARAMS.k;
Model.deg    = sPARAMS.deg;
Model.trainX = X;
Model.trainy = y;

if isfield(sPARAMS,'numindeces')
  Model.numindeces = sPARAMS.numindeces;
else
  Model.numindeces = inf;
end

if nargout>1
  deg  = Model.deg;
  len1 = size(X,2);
  len2 = size(Model.trainX,2);
  
  
  
  distance = zeros(len2,len1);
  for i = 1:len1,
      for j = 1:len2,
          distance(j,i) = sum( (abs(X(:,i)-Model.trainX(:,j)).^deg) ./ ...
              (X(:,i)+Model.trainX(:,j)) );
      end
  end

  maxdistance = max(distance(:));
  distance    = distance + eye(len1)*maxdistance;
  
  [sorted,index] = sort(distance);
  yy             = Model.trainy(index);
  if Model.k>1
    weights = mean(yy(1:Model.k,:),1)';
    disp('kNN weights::just sign no voting');
    labels  = sign(weights);
  else
    labels = yy(1,:)';
    weights = 1./(sorted(1,:)'+eps);
  end
  looerrors = mean(labels==y);
end
