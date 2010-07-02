%---------------------------------------------------
%sharat@mit.edu
%---------------------------------------------------
function C=confusion_matrix(GY,TY,lbl)
	C  =zeros(length(lbl));
	for l=1:length(lbl)
		idx = find(GY==lbl(l));
		for m=1:length(lbl)
			C(l,m)=sum(TY(idx)==lbl(m))/length(idx);
		end;
	end;
%end function