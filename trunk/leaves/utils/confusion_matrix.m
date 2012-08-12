%---------------------------------------------------
%sharat@mit.edu
%---------------------------------------------------
function C=confusion_matrix(GY,TY)
	whos GY, TY
	lbl = unique(GY);
	C  =zeros(length(lbl));
	for l=1:length(lbl)
		idx = find(GY==lbl(l));
		for m=1:length(lbl)
			if (isempty(idx))
				C(l,m) = 0;
			else
				C(l,m)=sum(TY(idx)==lbl(m))/length(idx);
			end;
		end;
	end;
%end function
