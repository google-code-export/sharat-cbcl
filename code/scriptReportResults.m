c%--------------------------------------------------------
%
%sharat@mit.edu
%
function reportResults(prefix)
resFiles=dir(sprintf('%s*',prefix));
nSplits =length(resFiles);
THRESH  =0:0.025:1;
det     =zeros(nSplits,length(THRESH));
totAcc=[];
for i=1:nSplits
    fprintf('Processing :%d\n',i);
    clear tstY tstPred;
    load(resFiles(i).name,'tstY','tstPred','trnY','trnPred');
    pos =tstPred(tstY==1);
    neg =tstPred(tstY~=1);
    trnPos=trnPred(trnY==1);
    trnNeg=trnPred(trnY~=1);
    for t=1:length(THRESH)
        th=quantile(trnNeg,1-THRESH(t));
        miss(t)=mean(trnPos<th);
        fp(t)  =mean(trnNeg>=th);
    end;
    merr = sum(fp+miss);
    idx  = find(merr==min(merr(:)),1);
    for t=1:length(THRESH)
        th  =quantile(neg,1-THRESH(t));
        det(i,t)=mean(pos>=th);
    end;
    totAcc(i)=mean(sign(tstPred(:)-0.5)==tstY(:));
end;
keyboard;
