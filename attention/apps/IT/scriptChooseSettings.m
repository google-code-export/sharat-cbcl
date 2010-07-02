function scriptChooseSettings
load set-001
acc=zeros(length(gSettings),1);
for i=1:length(gSettings)
  setFile=sprintf('trn-%03d.mat',i);
  if(~exist(setFile)) continue;end;
  fprintf('Processing:%d\n',i);
  load(setFile,'X','Y')
  acc(i)=getAccuracy(X,Y);
end;
keyboard;

function acc=getAccuracy(X,Y)
  count=0;
  [N,D]=size(X);
  %LOO
  for i=1:N
	tX=X;tY=Y;
	tX(i,:)=[];tY(i)=[];
	for j=unique(Y)
	  idx      =find(tY==j);
	  trnX(j,:)=tX(idx(1),:);%mean(tX(tY==j,:));
	  trnY(j)  =j;
	end;
	%d=[];
	%for j=unique(Y)
	%  tmp=corrcoef(trnX(j,:),X(i,:));
	%  d(j)=tmp(1,2);
	%end;
	d=negdist(trnX,X(i,:)');
	idx=find(d==max(d(:)),1);
    count=count+(length(d)-idx+1)/length(d);
  end;
  acc=count/size(X,1);
%end function

