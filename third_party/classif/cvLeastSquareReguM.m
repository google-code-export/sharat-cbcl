%--------------------------------------------------------------------------------------------
%sharat@mit.edu
%
%--------------------------------------------------------------------------------------------
function model = cvLeastSquareReguM(X,Y)
	lbl = unique(Y(:))'
	for c=1:length(lbl)
		tY      		=ones(length(Y),1);
		tY(Y~=lbl(c))	=-1;
		model{c}		=cvLeastSquareRegu(X,tY)
	end;
%end function