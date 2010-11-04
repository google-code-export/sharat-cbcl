%--------------------------------------------------------------------------------------------
%sharat@mit.edu
%
%--------------------------------------------------------------------------------------------
function [yhat,lbl] = cvLeastSquareReguMC(X,model)
	yhat =zeros(length(model),size(X,2));
	for c=1:length(model)
		val		=LeastSquareReguC(X,model{c});
		yhat(c,:)	=val(:)';
	end;
	yhat     =softmax(yhat);
	[tmp,lbl]=max(yhat,[],1);
%end function