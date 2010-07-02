function eval-svm
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
	trn{i}=cat(1,trn{i},tags(idx(1:200),:));
	tst{i}=cat(1,tst{i},tags(idx(201:300),:));
	pdf{i}=cat(1,pdf{i},mean(tags(idx(1:200),:)));
  end;
  %pdf{i}=repmat(cat(1,pdf{i},mean(trn{i})),8,1);
end;

if(~exist('splits.mat'))
  save('splits','trn','tst');
else
  load('splits','trn','tst');
end;
%-------------------------------
%use priors to classify
prec=[];recall=[]
for i=1:10
  class=tst{i}(:,1:8);
  tags=tst{i}(:,9:end);
  yhat=[];
  for t=1:size(tst{i},1)
	idx      =find(class(t,:));
	yhat(t,:)=pdf{i}(idx,:);
  end;
  [p,r]=evaluate(yhat(:,9:end),tags,10);
  prec(i)=p;
  recall(i)=r;
end;
keyboard;


