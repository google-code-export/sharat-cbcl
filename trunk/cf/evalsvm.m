function evalsvm
close all;
addpath('~/third_party/libsvm');
f=fopen('numeric-tags.txt','r');
tags=fscanf(f,'%d',[186 Inf])';
load('splits','trn','tst');
names=textread('files-cleaned.txt','%s');
%-------------------------------
%aggregate features
FEATURE_HOME='/cbcl/scratch01/sharat/databases/CF/labelme/features/gist';
fprintf('Aggregating..\n');
X=[];
if(~exist('tags-ssdb.mat'))
  for f=1:length(names)e
	[path,name,ext]=fileparts(names{f});
	ftrname=fullfile(FEATURE_HOME,[name '.mat']);
	load(ftrname,'gist');
	X=cat(1,X,gist(:)');
  end;  
  save('tags-ssdb.mat','X');
else
  load('tags-ssdb','X');
end;  

%use random projection to cut down the dimensions
X = X*randn(size(X,2),10);

%filter tags with low entropy
for t=1:size(tags,2)
  e(t)=entropy(tags(:,t),[0 1]);
end;

prec=[];recall=[]
acc =[];yhat={};%testing 
ycap={}; %training
for i=1:10
    trnX    =X(trn{i},:);
	tstX    =X(tst{i},:);
	yhat{i} =[];
    %for each tag
	try
    for t=1:size(tags,2)
	  trnY    =tags(trn{i},t)*2-1;
	  tstY    =tags(tst{i},t)*2-1;
	  if(all(trnY==-1))
		trnY(end)=1;%error
	  end;
	  %train
	  fprintf('Triaing SVM\n');
	  model=svmtrain(trnY,trnX,'-t 0 -b 1 -s 0 -w1 10');
	  %test
	  [lbl,acc,ytrn]=svmpredict(trnY,trnX,model);
	  [lbl,acc,ytst]=svmpredict(tstY,tstX,model);
	  %translate to probability
	  ytrn=ytop(ytrn,model.ProbA,model.ProbB);
	  ytst=ytop(ytst,model.ProbA,model.ProbB);
	  fprintf('Accuracy for tag:%d is %f\n',t,acc(1));
	  if(trnY(1)==1)
		yhat{i}(:,t)=ytst(:);
		ycap{i}(:,t)=ytrn(:);
	  else
		yhat{i}(:,t)=1-ytst(:);
		ycap{i}(:,t)=1-ytrn(:);
	  end;
	end;%t
  catch
	err=lasterror;
	disp('Error!');
	keyboard;
  end;
   DO_THRESH=0;
   for o=0:10
       if(DO_THRESH)
	        thresh=0.1:0.1:0.9;
            for t=1:length(thresh)
		     [p,r]=evaluate(ycap{i}(:,9:end)>=thresh(t),tags(trn{i},9:end));
		     f(t)=2*p*r/(p+r);
	        end;
	        t=thresh(find(f==max(f),1)); 
	        [p,r]=evaluate(insertgt(yhat{i}(:,9:end),tags(tst{i},9:end),o)>=t,tags(tst{i},9:end));
        else
	     [p,r]=evaluate(insertgt(yhat{i}(:,9:end),tags(tst{i},9:end),o),tags(tst{i},9:end),5);
    end;
    prec(i,o+1)=p;
    recall(i,o+1)=r;
  end;  
end;
fmeasure=2*prec.*recall./(prec+recall+eps);
save('svm-results','prec','recall','fmeasure');

function yhat=insertgt(yhat,tags,N)
    if(N==0) return;end;
    for t=1:size(yhat,1)
        idx=find(tags(t,:));
        idx=idx(randperm(length(idx)));
        yhat(t,idx(1:min(length(idx),N)))=1;
    end;
function t=findthresh(y,Y)
   miny=min(y);
   maxy=max(y);
   thresh=linspace(miny(1),maxy(1),75);
   pos=find(Y==1);
   neg=find(Y~=1);
   err=[];
   for t=1:length(thresh)
	 err(t)=sum(y(pos)<thresh(t));%+sum(y(neg)>=thresh(t));
   end;
   t=thresh(find(err==min(err),1));
%end;

function y=ytop(y,ProbA,ProbB)
	  y=y*ProbA+ProbB;
	  pos=find(y>0);neg=find(y<0);
	  y(pos)=exp(-y(pos))./(1+exp(-y(pos)));
	  y(neg)=1./(1+exp(y(neg)));
%end;
