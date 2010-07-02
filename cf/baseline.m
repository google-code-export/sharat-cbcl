function baseline
close all;
f=fopen('numeric-tags.txt','r');
tags=fscanf(f,'%d',[186 Inf])';

%create the splits
trn={};
tst={};
pdf={};
for i=1:10
  trn{i}=[];
  tst{i}=[];
  pdf{i}=[];
  fprintf('Creating split:%d\n',i);
  for c=1:8
	idx=find(tags(:,c)==1);
	idx=idx(randperm(length(idx)));
	trn{i}=cat(1,trn{i},idx(1:200));
	tst{i}=cat(1,tst{i},idx(201:300));
    %class conditional
	%pdf{i}=cat(1,pdf{i},mean(tags(idx(1:200),:)));
  end;
  %prior
  pdf{i}=cat(1,pdf{i},repmat(mean(tags(trn{i},9:end)),8,1));
end;

if(~exist('splits.mat'))
  save('splits','trn','tst');
else
  load('splits','trn','tst');
end;
%-------------------------------
%use priors to classify
prec=[];recall=[]
tagsOrg=tags;
for i=1:10
  for o=0:10
      try
	    fprintf('Split:%d\n',i);
	    class=tagsOrg(tst{i},1:8);
	    tags=tagsOrg(tst{i},9:end);
	    yhat=[];
	    for t=1:size(tst{i},1)
	        idx      =find(class(t,:));
	        yhat(t,:)=pdf{i}(idx,:);
            %oracle sets some of the tags
            idx      =find(tags(t,:));
            if(length(idx)>0 & o>0)
                idx      =idx(randperm(length(idx)));
                yhat(t,idx(1:min(o,end)))=1;
            end;
	    end;
    	[p,r]=evaluate(yhat,tags,10);
    	%[p,r]=evaluate(yhat>0.1,tags);
	    prec(i,o+1)=p;
	    recall(i,o+1)=r;
      catch
	        err=lasterror;
	        disp('Error!');
	        keyboard;
       end;     
    end;%o
end;%i
fmeasure=2*prec.*recall./(prec+recall+eps);
mean(fmeasure)
save('baseline-results','prec','recall','fmeasure')


