%-----------------------------------------------------
%
%sharat@mit.edu
function scriptClassifyJointBoost(pRank)
   DEBUG=1;
   srcHome='/data/scratch/sharat';
   addpath(fullfile(srcHome,'utils'));
   addpath(fullfile(srcHome,'third_party','classif'));
   addpath(fullfile(srcHome,'third_party','sharing'));
   %-------------------------
   %training data
   sprintf('Processing split:%d',pRank+1);
   load training_data X Y;
   if(DEBUG)
       X  =randn(100,size(X,1))*X;%random projection
   end;
   %-----------------------------
   %create sharing matrix
   nClasses       =length(unique(Y));
   for i=0:2^nClasses-1
       bits    =dec2bin(i,nClasses);
       T(:,i+1)=bits(:)-'0';
   end;
   T(:,sum(T)<5)  =[];
   orgY           =Y;
   [trnSet,tstSet]=split_data(Y,2,1);
   trnX          = X(:,trnSet{1});trnY=Y(trnSet{1});
   tstX          = X(:,tstSet{1});tstY=Y(tstSet{1});
   %------------------------------
   %equalize number of classes
   nSamples       =hist(trnY);
   nFtr           =size(trnX,1);
   maxSamples     =max(nSamples);
   X              =zeros(nFtr,maxSamples*nClasses);
   Y              =zeros(1,maxSamples*nClasses);
   sample         =0;
   for n=1:nClasses
       idx = find(trnY==n);
       for s=1:maxSamples
           ridx=randperm(length(idx));
           idx =idx(ridx(1));
           sample=sample+1;
           X(:,sample)=trnX(:,idx);
           Y(sample)   =n;
       end;
   end;
   model         = jointBoosting(X,Y,T,50,100);
   [tstPred, tstFx,tstFn,tstFstumps]=strongJointClassifier(tstX, model, T);
   [trnPred, trnFx,trnFn,trnFstumps]=strongJointClassifier(trnX, model, T);
   resFile=sprintf('results_boost_%03d',pRank+1);
   save(resFile,'trnPred','tstPred','trnY','tstY','trnSet','tstSet',...
                'trnFx','tstFx','trnFn','tstFn','tstFstumps','trnFstumps');
%end function
