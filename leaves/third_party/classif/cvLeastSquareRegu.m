function model = cvLeastSquareRegu(Xtr, Y)
	%split the data
	Y				 = Y(:);
	[cv_set,trn_set] = split_data(Y,3,1);
	if(0)
	err =[]; 
    nPos=sum(Y>0);
    nNeg=sum(Y<0);
	sval=logspace(-2,1,4);
	lval=logspace(-4,-2,3);
	for s=1:length(sval);
		for l=1:length(lval);
			err(s,l)=0;
			for split=1:length(cv_set)
				model=LeastSquareRegu(Xtr(:,trn_set{split}),Y(trn_set{split}),...
									  struct('l',lval(l),'s',sval(s),'k','gaussian'));
				F    =LeastSquareReguC(Xtr(:,cv_set{split}),model);
				pidx =find(Y(cv_set{split})>0);
				nidx =find(Y(cv_set{split})<0);
				miss =mean(sign(F(pidx))<0);
				fp   =mean(sign(F(nidx))>0);
				err(s,l)=err(s,l)+max(miss,fp)
			end;
		end;
	end;
	%find the best
	[i,j]=find(err==min(err(:)),1);
  	model=LeastSquareRegu(Xtr,Y,struct('s',sval(i),'l',lval(j),'k','gaussian'));
    else
	  model=LeastSquareRegu(Xtr,Y,struct('s',.1,'l',1e-4,'k','gaussian'));
    end;
  
