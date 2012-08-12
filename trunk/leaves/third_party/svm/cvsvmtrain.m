function model = cvsvmtrain(Y,Xtr)
	%split the data
	Y				 = Y(:);
	cval=logspace(-2,1,4);
	gval=logspace(-2,2,5);
	acc = zeros(length(cval), length(gval));
	for s=1:length(cval);
		for l=1:length(gval);
			params=sprintf('-t 2 -c %f -g %f -e 0.01 -m 2048 -v 3',cval(s),gval(l));
			acc(s,l) = svmtrain(Y,Xtr,params);
		end;
	end;
	%find the best
	[i,j]=find(acc==max(acc(:)),1);
	params = sprintf('-t 2 -c %f -g %f -m 2048',cval(i),gval(j))
 	model=svmtrain(Y,Xtr,params)
%end function  
