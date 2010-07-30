%--------------------------------------------------------
%
%sharat@mit.edu
%
function scriptReportMulticlass(folder,prefix)
resFiles=dir(fullfile(folder,sprintf('%s*',prefix)));
nSplits =length(resFiles);
THRESH  =0:0.025:1;
det     =zeros(nSplits,length(THRESH));
for i=1:nSplits
    fprintf('Processing :%d\n',i);
    clear tstY tstPred;
    load(fullfile(folder,resFiles(i).name),'tstY','tstPred','trnY','trnPred');
    [val,tstLbl]=max(tstPred,[],2);
    if(0) %remove classes 2 and 3
        idx=find(tstY==1 | tstY==3 | tstY==5);
        tstY(idx)     =[];
        tstPred(:,[1 3 5])=[];
        tstPred(idx,:)=[];
        tstLbl(idx)   =[];
    end;
    if(0)
    for l=1:length(labels)
        [A,B]=calibrate_output(trnPred(:,l),trnY==labels(l));
        tstPred(:,l)=1./(1+exp(A*tstPred(:,l)+B));
    end;
    end;
    labels      =unique(tstY)';
    totAcc(i)   =mean(tstLbl(:)==tstY(:));
    for l=1:length(labels)
        for m=1:length(labels)
            acc(l,m,i)=mean(tstLbl(tstY==labels(l))==labels(m));
        end;
    end;
end;
keyboard;
