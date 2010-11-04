function model = cvsvmtrain(Y,Xtr,skip)
	%split the data
	Y				 = Y(:);
	[cv_set,trn_set] = split_data(Y,3,1);
	%reduce data by half
	if(nargin<3)
	  skip=1;
	end;  
	for i=1:length(cv_set)
	  cv_set{i}=cv_set{i}(1:skip:end);
	end;
	for i=1:length(trn_set)
	  trn_set{i}=trn_set{i}(1:skip:end);
	end;  
	if(1)
	err =[]; 
    nPos=sum(Y>=0);
    nNeg=sum(Y<0);
	cval=logspace(-2,1,4);
	wval=logspace(-2,1,4)*nNeg/(nPos+1);
	for s=1:length(cval);
		for l=1:length(wval);
			err(s,l)=0;
			for split=1:length(cv_set)
			    params=sprintf('-t 0 -c %.4f -w1 %.4f -w-1 1 -e 0.01 -m 4096',cval(s),wval(l));
				fprintf('Evaluating params:%s\n',params);
				%make sure first label is 1
				Ytr           = Y(trn_set{split});
				idx           = [find(Ytr>0);find(Ytr<0)];
				trn_set{split}= trn_set{split}(idx);
				model   = svmtrain(Y(trn_set{split}),Xtr(trn_set{split},:),params);
				[a,b,F] = svmpredict(Y(cv_set{split}),Xtr(cv_set{split},:),model);
				pidx    = find(Y(cv_set{split})>=0);if(isempty(pidx)) pidx=1;end;
				nidx    = find(Y(cv_set{split})<0); if(isempty(nidx)) nidx=1;end;
				miss    = mean(sign(F(pidx))<0);
				fp      = mean(sign(F(nidx))>=0);
				fprintf('FP:%f,MISS:%f\n',fp,miss);
				err(s,l)= err(s,l)+max(miss,fp)
			end;
		end;
	end;
	%find the best
	[i,j]=find(err==min(err(:)),1);
  	model=svmtrain(Y,Xtr,sprintf('-t 0 -c %f -w1 %d -w-1 1 -m 4096',cval(i),wval(j)));
    else
	  model=svmtrain(Y,Xtr,'-t 0 -c 1');
	end;
%end function  
