%------------------------------------------------------------------------
%
%sharat@mit.edu
%------------------------------------------------------------------------
function out = calibrate_output(X,Y)
	  X = X(:);Y=Y(:);
	  [x,fval,flag]=fminunc(@(x) fitness(x,X,Y==1),[-1;0],optimset('Display','iter'));
	  A            =x(1);
	  B            =x(2);
	  out          =1./(1+exp(A*X+B));