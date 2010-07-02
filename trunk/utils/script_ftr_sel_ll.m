function [sel]=script_ftr_sel_ll(trnX,trnY,N)
	if(nargin<5)
		N=100;
	end;
	m0    = mean(trnX(trnY==1,:));m1=mean(trnX(trnY==2,:));
	[tmp,idx]=sort(m1./m0,'descend');
	sel   = idx(1:N);
%end function	
