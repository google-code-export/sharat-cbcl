function evalcf
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
  for f=1:length(names)
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

prec=[];recall=[]
acc =[];yhat={};%testing 
ycap={}; %training
for i=1:10
    trnX    =X(trn{i},:);
	tstX    =X(tst{i},:);
	mX      =mean(trnX);
	%run kmeans
	[idx,C,sumD,D] =kmeans(trnX,50);
	sigma          =mean(D(:));
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
    %-------------------------------------
    %compute similarity
    tstTag=tags(tst{i},9:end);
    trnTag=tags(trn{i},9:end);
    alpha=getbestalpha(trnX,trnTag);
    for o=0:10
        ycap=insertgt(zeros(size(tstTag)),tstTag,o);
        sim=simdist(tstX,trnX,ycap,trnTag,alpha);
        yhat{i} =sim*(tags(trn{i},:)*2-1);
        %for each tag
        DO_THRESH=0;
        if(DO_THRESH)
          thresh=0.1:0.1:0.9;
          for t=1:length(thresh)
             [p,r]=evaluate(ycap{i}(:,9:end)>=thresh(t),tags(trn{i},9:end));
             f(t)=2*p*r/(p+r);
           end;
           t=thresh(find(f==max(f),1)); 
           [p,r]=evaluate(yhat{i}(:,9:end)>=t,tags(tst{i},9:end));
         else
           [p,r]=evaluate(max(yhat{i}(:,9:end),ycap),tags(tst{i},9:end),5);
         end;
         fprintf('F-measure(split:%d,tags:%d) is:%f\n',i,o,2*p*r/(p+r));
	     prec(i,o+1)=p
	     recall(i,o+1)=r
    end;     
end;
fmeasure=2*prec.*recall./(prec+recall);
save('cf-results','prec','recall','fmeasure');

function alpha=getbestalpha(X,tag)
        nX=size(X,1);
        nTrn=ceil(nX*0.75);
        arange=logspace(log10(0.001),log10(10),16);
        perf=[];
        for s=1:4
            idx=randperm(nX);
            trnX=X(idx(1:nTrn),:);trnTag=tag(idx(1:nTrn),:);
            tstX=X(idx(nTrn+1:end),:);tstTag=tag(idx(1+nTrn:end),:);
            for a=1:length(arange)
                sim=simdist(tstX,trnX,tstTag,trnTag,arange(a));
                yhat=sim*(trnTag*2-1);
                [p,r]=evaluate(yhat,tstTag,5);
                f=2*p*r/(p+r);
                perf(s,a)=f
           end;
        end; 
        meanperf=mean(perf);
        idx=find(meanperf==max(meanperf(:)),1);
        alpha=arange(idx);

function sim=simdist(tstX,trnX,tstTag,trnTag,alpha)
   nTst=size(tstX,1);
   dist=-negdist(trnX,trnX');sigma=mean(dist(:));
   dist=-negdist(tstX,trnX');
   sigma=mean(dist(:));
   for u=1:nTst
       w1=exp(-dist(u,:).^2/(2*sigma*sigma));
       w2=trnTag*tstTag(u,:)';
       sim(u,:)=(w2(:)+alpha).*w1(:);
   end;
	for u=1:nTst
	  [val,idx]=sort(sim(u,:),'descend');
	  sim(u,idx(20:end))=0;
  	  sim(u,:)=sim(u,:)/sum(sim(u,:)+eps);
	end;
	
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
