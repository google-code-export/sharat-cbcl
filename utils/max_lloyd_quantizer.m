%----------------------------------------------------------------------------------------------------
%max_lloyd_quantizer
%
% max_lloyd_quanitzer for the continuous case. 
% x - histogram edges (histogram must be computed using histc)
%   - assumes x is in increasing order
% px- probability values for the histogram
%   - px(a) = P(x(a)<X<x(a+1))
% M - number of levels
%----------------------------------------------------------------------------------------------------
function [a,y] = max_lloyd_quantizer(x,px,M,mn,mx)
  %-----------------------------
  %initial guess at equal quantiles
  %-----------------------------
  if(0)
  psum = cumsum(px);
  a    = zeros(1,M+1);
  y    = zeros(1,M);
  a(1) = mn;%x(1);
  for i = 1:M-1
    idx   = find(psum>=i/M);
    a(i+1)= x(idx(1));
  end;
  a(end)  = mx;%x(end);
  else
  %-------------------------------
  %random initialization
  %------------------------------
  a    = mn+(mx-mn-eps)*rand(1,M-1);
  %-------------------------------
  %logspace initialization
  %------------------------------
  %a= logspace(log10(min(x)+eps),log10(max(x)),M+1);
  a = [mn,sort(a),mx]; 
  end;
  y = get_centroids(a,x,px);
  old_err=error_variance(a,y,x,px);
  err = 0;
  TOL = 1e-3;
  while(abs(err-old_err)/abs(old_err)>TOL)
    err = old_err;
    y   = get_centroids(a,x,px);
    %--------------------------
    %a(1) a(M+1) are fixed
    %-------------------------
    for j=2:M
     a(j) = 0.5*(y(j-1)+y(j));
    end;
    old_err= error_variance(a,y,x,px);
    fprintf('~%f\n',abs(err-old_err));
  end;
%end function 


%------------------------------------
%
%------------------------------------
function y  = get_centroids(a,x,px)
  M = length(a)-1;
  for i=1:M
    idx  = find(x>=a(i) & x<a(i+1));
    y(i) = sum(x(idx).*px(idx))/(sum(px(idx))+eps);
    if(sum(px(idx))==0)
      y(i) = (a(i)+a(i+1))/2;
    end;
  end;
%end function 

%-------------------------------------------
%
%-------------------------------------------
function err=error_variance(a,y,x,px)
  M   = length(a)-1;
  err = 0;
  for i = 1:M
     idx  = find(x>=a(i) & x<a(i+1));
     err  = err+sum(px(idx).*(x(idx)-y(i)).^2);	
  end;
%end function 
