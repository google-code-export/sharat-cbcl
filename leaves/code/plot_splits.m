clear all;
%close all;
%HOME     = '/data/scratch/sharat/data/leaves-ftr';
%HOME     = '/data/scratch/sharat/data/lgn-leaves-features';
%HOME     = '/data/scratch/sharat/data/lgn-sparse-features';
%HOME     = '/data/scratch/sharat/data/leaves-pixel';
HOME     = '/data/scratch/sharat/data/AnimalFeatures';
PREFIX   = 'split_c2_0*results.mat';
d        = dir(fullfile(HOME,PREFIX));
CLEN     = 8;
trn_acc  = zeros(length(d),CLEN);
tst_acc  = zeros(length(d),CLEN);
for i=1:length(d)
 fprintf('loading %s/%s\n',HOME,d(i).name);
 tmp= load(fullfile(HOME,d(i).name));
 for j=1:CLEN
   trn_acc(i,j)=tmp.trn_acc{j}(1);
   tst_acc(i,j)=tmp.tst_acc{j}(1);
 end;
 TRIAL = 1;
 gtY =tmp.tstY;
 tstY=tmp.tst_lbl{TRIAL};
 labels  = unique(tmp.trnY)'
 %if(length(labels)==2) %binary
 %	labels(labels==-1)=2;
 %end;
 conf    = zeros(length(labels));
 for l = 1:length(labels)
	for m = 1:length(labels)
		conf(l,m) = sum(tstY(gtY==labels(l))==labels(m));
    end;
	conf(l,:)=conf(l,:)/sum(conf(l,:));
 end;
end;
macc=mean(tst_acc,1)';
sacc=std(tst_acc,[],1)';
return;
