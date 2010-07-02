function out=c12vec(c1)
	out=[];
	for b=1:length(c1)
		out=cat(1,out,c1{b}(:));
	end;
%end function
