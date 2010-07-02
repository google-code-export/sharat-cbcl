function evalcfitem
close all;
addpath('~/third_party/libsvm');
f=fopen('numeric-tags.txt','r');
tags=fscanf(f,'%d',[186 Inf])';tags=tags(:,9:end);
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
X = X*randn(size(X,2),100);
%tags=2*tags-1;

prec=[];recall=[]
acc =[];yhat={};%testing 
ycap={}; %training
for i=1:10
    yhat{i}=[];
    trnX    =X(trn{i},:);
	tstX    =X(tst{i},:);
	%run kmeans
	[idx,C,sumD,D] =kmeans(trnX,5);
	sigma          =mean(D(:));
	keyboard;
	%transform vectors
	trnX    = negdist(trnX,C');
	tstX    = negdist(tstX,C');
	trnX    = exp(-trnX.^2/(2*sigma*sigma));
	tstX    = exp(-tstX.^2/(2*sigma*sigma));
	for u=1:size(trnX,1)
	  trnX(u,:)=trnX(u,:)/sum(trnX(u,:));
	end;
	for u=1:size(tstX,1)
	  tstX(u,:)=tstX(u,:)/sum(tstX(u,:));
	end;
	%-------------------------------
	%compute similarity matrix
	%
	fprintf('Computing similarity\n');
	sim=zeros(size(trnX,2),size(tags,2));
	for u=1:size(trnX,2)
	  for v=1:size(tags,2)
		%cf=corrcoef(trnX(:,u),tags(trn{i},v));
		sim(u,v)=dot(trnX(:, u),tags(trn{i},v))/norm(trnX(:,u)+eps)/norm(tags(trn{i},v)+eps);
	  end;
	end;
	keyboard;
	sim=sim./(repmat(sum(abs(sim)),size(sim,1),1)+0.01);
	%for v=1:size(sim,2)
	  %sim(:,v)=sim(:,v)/(sum(abs(sim(:,v)))+eps);
	%end;
	for u=1:size(tstX,1)
	  %get the closest
	  yhat{i}(u,:)=tstX(u,:)*sim;
	end;
	keyboard;
    %for each tag
	[p,r]=evaluate(yhat{i},tags(tst{i},:),5);
    fprintf('F-measure is:%f\n',2*p*r/(p+r));
	prec(i)=p
	recall(i)=r
	break;
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
