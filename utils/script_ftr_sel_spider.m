%------------------------------------------------------------------------------
%
%
%sharat@mit.edu
%uses broadcast tag 70000
%-----------------------------------------------------------------------------
function [idx,MODEL] = script_ftr_sel_spider(X,Y,NORMALIZE)
    addpath(genpath('/data/scratch/sharat/third_party/spider'));
    warning('off','all');
    if(nargin<3)
      NORMALIZE    = 0;
    end;
    MAX_ITER     = 20;
    THRESH       = 1e-4;
    MIN_DIM      = 1;
    idx          = [];
    if(NORMALIZE)
      mX         = mean(X,1);
      sX         = std(X,[],1);
      X          = X-repmat(mX,size(X,1),1);
      X          = spdiag(1./(sX+eps))*X;
    end;
    trn          = data(X,Y);
    for i = 1:MAX_ITER
	LABELS  = unique(Y);
	LABELS  = LABELS(1:end-1);%assume last is background
	W       = zeros(size(X,2),length(LABELS));
	b       = zeros(length(LABELS),1);
        for lbl = LABELS %assume last is background
	  fprintf('Processing label:%d\n',lbl);
	  trn.Y(Y==lbl,1)=1;
	  trn.Y(Y~=lbl,1)=-1;
	  [tr,MDL]   = train(svm('C=0.1;alpha_cutoff=-2'),trn);
	  W(:,lbl)   = get_w(MDL)';
	  b(lbl)     = MDL.b0;
        end;  
        %---------------------------------
        %weigh the data
        %---------------------------------
        w     = sum(abs(W),2);
        trn.X = trn.X*spdiag(w);
        idx   = find(abs(w)>THRESH);
        nfeat = length(idx);
	MODEL{i}.nfeat = nfeat;
        MODEL{i}.idx   = idx;
	MODEL{i}.w     = w;
	if(NORMALIZE)
	  MODEL{i}.mX    = mX(idx);
	  MODEL{i}.sX    = sX(idx);
	end;
        %----------------------------------
        %
        %----------------------------------
	if(0)
        %prepare training data 
	tmpY         = -ones(size(X,1),length(LABELS));
	for l = unique(Y')
	  lidx = find(Y==l);
          fprintf('setting :%d\n',l);
	  tmpY(lidx,l)=1;
        end;
	[tr,model]   = train(one_vs_rest(svm),data(X(:,idx),tmpY));
	tst          = test(model,data(X(:,idx),tmpY));
	MODEL{i}.err = 0;%mean(tst.X(:,1)~=tmpY(:,1));
	MODEL{i}.model = model;
	end;
	fprintf('Done with iteration:%d (active features:%d)\n',i,nfeat);
         if(nfeat < MIN_DIM)
         break;
	end;
	save('model_sel','MODEL');   
    end;
    idx = MODEL{i}.idx;
%end function


