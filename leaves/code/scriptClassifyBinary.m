%-----------------------------------------------------
%
%sharat@mit.edu
function scriptClassifyBinary(pRank)
   DEBUG=1;
   srcHome='/data/scratch/sharat';
   addpath(fullfile(srcHome,'utils'));
   addpath(fullfile(srcHome,'third_party','classif'));
   %-------------------------
   %training data
   sprintf('Processing split:%d',pRank+1);
   load training_data_mc X Y;
   if(DEBUG)
       X   =X(1:384,:);
       %X  =randn(1000,size(X,1))*X;
   end;
   Y              =remap(Y,{[4],[1:3,5:8]},[1 -1]);
   orgY           =Y;
   [trnSet,tstSet]=split_data(Y,2,1);

     trnX          = X(:,trnSet{1});trnY=Y(trnSet{1});
     tstX          = X(:,tstSet{1});tstY=Y(tstSet{1});
     nSamples      = hist(trnY,[-1 1])
     maxSamples    = max(nSamples)
     pidx          = find(trnY>0);
     nidx          = find(trnY<0);
     tX            = zeros(size(trnX,1),maxSamples*2);
     tY            = zeros(maxSamples*2,1);
     for s=1:maxSamples
       ridx        = randperm(length(pidx));ridx=ridx(1);
       tX(:,2*s-1) = trnX(:,pidx(ridx)); 
       tY(2*s-1)   = 1;
       ridx        = randperm(length(nidx));ridx=ridx(1);
       tX(:,2*s)   = trnX(:,nidx(s));
       tY(2*s)     = -1;
     end;
     model         = cvLeastSquareRegu(tX,tY);
     pred          = LeastSquareReguC(trnX,model);
     A             = -1;
     B             = 0;
     %[A,B]        = calibrate_output(pred(:),trnY(:))
     trnPred       = 1./(1+exp(A*pred+B));
     pred          = LeastSquareReguC(tstX,model);
     tstPred       = 1./(1+exp(A*pred+B));
     resFile=sprintf('results_binary_new_%03d',pRank+1);
     save(resFile,'trnPred','tstPred','trnY','tstY','trnSet','tstSet');
%end function
