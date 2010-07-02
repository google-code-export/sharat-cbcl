function evalinf_nosvm
close all;
addpath('~/third_party/libsvm');
addpath(genpath('~/third_party/c_inference'));
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
X = X*randn(size(X,2),10);

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
   %build adj matrix
    trnTag=tags(trn{i},9:end);
    tstTag=tags(tst{i},9:end);
    ytst=mean(trnTag);
    ytst=repmat(ytst,size(tstTag,1),1);
    for o=0:10
        lambda=getLambda(trnTag);
        %adjMatrix=zeros(size(tstTag,2));
        %for t=1:size(trnTag,2)
        %    for u=1:size(trnTag,2)
        %        l(u)=lambda{t,u}(1,1);
        %    end;    
        %    l(t)=0;
        %    [val,idx]=sort(l,'descend');
        %    adjMatrix(t,idx(1:10))=1;
        %end;    
        adjMatrix=ones(size(tstTag,2))-eye(size(tstTag,2));
        ycapTag=insertgt(zeros(size(tstTag)),tstTag,o);
        %-------------------------------
        %get svm predictions
        %do inference
        ycap=[];
        for n=1:size(tstTag,1)
            local=cell(1,size(tstTag,2));
            for t=1:size(tstTag,2)
                local{t}=[max(ycapTag(n,t),ytst(n,t));1-max(ycapTag(n,t),ytst(n,t))];
            end;    
            [bel,converged]=inference(adjMatrix,lambda,local,'loopy');
            for t=1:size(tstTag,2)
                ycap(n,t)=bel{t}(1);
            end;    
        end;
        %for each tag
        [p,r]=evaluate(ycap,tags(tst{i},9:end),5);
        fprintf('F-measure(split:%d,tags:%d) is:%f\n',i,o,2*p*r/(p+r));
	    prec(i,o+1)=p
	    recall(i,o+1)=r
    end;     %o
end;%i
fmeasure=2*prec.*recall./(prec+recall);
save('inf-nosvm-results','prec','recall','fmeasure');

function lambda=getLambda(trnTag)
  lambda=cell(size(trnTag,2));
  for s=1:size(trnTag,2)
      for t=1:size(trnTag,2)
          p11=mean(trnTag(:,s)&trnTag(:,t));
          p10=mean(trnTag(:,s)&~trnTag(:,t));
          p01=mean(~trnTag(:,s)&trnTag(:,t));
          p00=mean(~trnTag(:,s)&~trnTag(:,t));
          lambda{s,t}=[p11 p10;p01 p00];
      end;
   end;   

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

function [trnRes,tstRes]=getSVMScore(trnX,trnTags,tstX,tstTags)
trnRes=[];
tstRes=[];
for t=1:size(trnTags,2)
	  trnY    =trnTags(:,t)*2-1;
	  tstY    =tstTags(:,t)*2-1;
	  if(all(trnY==-1))
		trnY(end)=1;%error
	  end;
	  %train
	  fprintf('Triaing SVM\n');
	  model=svmtrain(trnY,trnX,'-t 0 -b 1 -s 0 -w1 10');
	  %test
	  [lbl,acc,ytrn]=svmpredict(trnY(:),trnX,model);
	  [lbl,acc,ytst]=svmpredict(tstY(:),tstX,model);
	  %translate to probability
	  ytrn=ytop(ytrn,model.ProbA,model.ProbB);
	  ytst=ytop(ytst,model.ProbA,model.ProbB);
	  fprintf('Accuracy for tag:%d is %f\n',t,acc(1));
	  if(trnY(1)~=1)
		ytst=1-ytst(:);
		ytrn=1-ytrn(:);
	  end;
      trnRes(:,t)=ytrn;
      tstRes(:,t)=ytst;
end;	
