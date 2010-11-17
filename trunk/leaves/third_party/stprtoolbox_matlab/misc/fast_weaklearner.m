function model = fast_weaklearner(data)
% WEAKLEARNER Produce classifier thresholding single feature.
%
% Synopsis:
%  model = weaklearner(data)
%
% Description:
%  This function produce a weak binary classifier which assigns
%  input vector x to classes [1,2] based on thresholding a single 
%  feature. The output is a model which defines the threshold 
%  and feature index such that the weighted error is minimized.
%  This weak learner can be used with the AdaBoost classifier
%  (see 'help adaboost') as a feature selection method.
%  
% Input:
%  data [struct] Training data:
%   .X [dim x num_data] Training vectors.
%   .y [1 x num_data] Binary labels (1 or 2).
%   .D [1 x num_data] Weights of training vectors (optional).
%    If not given then D is set to be uniform distribution.
% 
% Output:
%  model [struct] Binary linear classifier:
%   .W [dim x 1] Normal vector of hyperplane.
%   .b [1x1] Bias of the hyperplane.
%   .fun = 'linclass'.
%
% Example:
%  help adaboost
%
% See also: 
%  ADABOOST, ADACLASS.
% 

% About: Statistical Pattern Recognition Toolbox
% (C) 1999-2004, Written by Vojtech Franc and Vaclav Hlavac
% <a href="http://www.cvut.cz">Czech Technical University Prague</a>
% <a href="http://www.feld.cvut.cz">Faculty of Electrical Engineering</a>
% <a href="http://cmp.felk.cvut.cz">Center for Machine Perception</a>

% Modifications:
% 25-aug-2004, VF
% 11-aug-2004, VF
% 01-dec-2006, SC , sharat@mit.edu

[dim,num_data] = size(data.X);
if(~isfield(data,'D'))
    data.D = ones(1,num_data)/num_data;
end;

W = zeros(dim,1);
b = zeros(dim,1);
Errors    = zeros(dim,1);
%[sX,sidx] = sort(data.X,2);
for i=1:dim,
  %x       = sX(i,:);
  %idx     = sidx(i,:);
  [x,idx] = sort(data.X(i,:));
  y       = data.y(idx);
  D       = data.D(idx);
  Sp      = zeros(1,num_data);
  Sn      = zeros(1,num_data);
  Sp(y==1)      = D(y==1);
  Sn(y==2)      = D(y==2); 
  Sp            = cumsum(Sp); 
  Sn            = cumsum(Sn);
  Tp            = Sp(end);
  Tn            = Sn(end);
  err           = (Sp+Tn-Sn);
  [minerr1,inx1]= min(err);
  [minerr2,inx2] = min(Tp-Sp+Sn);
  if minerr1 < minerr2,
    W(i) = 1;
    Errors(i) = minerr1;
    b(i) = -x(inx1)-eps;
  else
    W(i) = -1;
    Errors(i) = minerr2;
    b(i) = x(inx2)+eps;
  end
end
[dummy,inx] = min(Errors);
model.W = zeros(dim,1);
model.W(inx) = W(inx);
model.b = b(inx);
model.fun = 'linclass';
model.dim = inx;
y = linclass(data.X,model);
err = sum((y(:)~=data.y(:)).*data.D(:));
return;
