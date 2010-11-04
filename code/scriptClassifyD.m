%-----------------------------------------------------
%
%sharat@mit.edu
function scriptClassifyD(pRank)
   DEBUG=0;
   srcHome='/data/scratch/sharat';
   addpath(fullfile(srcHome,'utils'));
   addpath(fullfile(srcHome,'third_party','classif'));
   %-------------------------
   %training data
   sprintf('Processing split:%d',pRank+1);
   load training_data_8of8ClassesContour X Y;
   load training_data_D D;
   orgY           =Y;
   [tstSet,trnSet]=split_data(Y,2,1);
   for lbl=unique(orgY(:))'
     fprintf('Label:%d\n',lbl);
     Y(orgY==lbl)  = 1;
     Y(orgY~=lbl)  =-1;
     len           = length(tstSet{1});
     idx           = randperm(len);
     idx           = idx(1:ceil(len/4));
     X             = [squeeze(D(idx,:,1)),squeeze(D(idx,:,2))];%,squeeze(D(idx,:,3))];
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
     trnPred(:,lbl)= 1./(1+exp(A*pred+B));
     pred          = LeastSquareReguC(tstX,model);
     tstPred(:,lbl)= 1./(1+exp(A*pred+B));
   end;
   trnY   =orgY(trnSet{1});
   tstY   =orgY(tstSet{1});
   resFile=sprintf('results_8of8Contour_%03d',pRank+1);
   save(resFile,'trnPred','tstPred','trnY','tstY','trnSet','tstSet','model');
%end function
