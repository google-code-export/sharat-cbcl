clear all;
close all;
NFTR=24;
addpath('~/utils');
addpath('~/lgn');
addpath('~/ulmann/code');
addpath(genpath('~/third_party/stprtool'));
load training_data X Y
Y=remap(Y,{[0:2],[3],[4],[5],[6],[7:8]},[4,1,2,4,3,4]);
[sel,th,mi,min]=script_ftr_sel_mi(X',Y',NFTR);
%[sel,th,alpha]=script_ftr_sel_adaboost(X',Y',NFTR);
%
X=X(:,sel);
for o=1:4
  for f=1:length(sel)
	p(f,o)=mean(X(Y==o,f)>=th(f));
  end
end;
p(:,end+1)=0.5;

