%------------------------------------------------------------------------------
%
%
%sharat@mit.edu
%uses broadcast tag 70000
%-----------------------------------------------------------------------------
function [idx,MODEL] = script_ftr_sel_spider(X,Y,MIN_DIM)
    addpath(genpath('/data/scratch/sharat/third_party/libsvm'));
    warning('off','all');
    NORMALIZE    = 0;
    MAX_ITER     = 20;
    THRESH       = 1e-4;
	if(nargin<3)
	    MIN_DIM      = 200;
    end;
    idx          = [];
    if(NORMALIZE)
      mX         = mean(X,1);
      sX         = std(X,[],1);
      X          = X-repmat(mX,size(X,1),1);
      X          = spdiag(1./(sX+eps))*X;
    end;
    trn          = struct('Y',Y);
    for i = 1:MAX_ITER
		LABELS  = unique(Y);
		LABELS  = LABELS(1:end-1);%assume last is background
		W       = zeros(size(X,2),length(LABELS));
		b       = zeros(length(LABELS),1);
        for lbl = LABELS %assume last is background
	  		fprintf('Processing label:%d\n',lbl);
	  		trn.Y(Y==lbl,1)=1;
	  		trn.Y(Y~=lbl,1)=-1;
	  		model = svmtrain(trn.Y,X,'-t 0 -c 1');
	  		hplane= model.sv_coef'*model.SVs;
	  		W(:,lbl)=hplane;
        end;  
        %---------------------------------
        %weigh the data
        %---------------------------------
        w     = sum(abs(W),2);
        X     = X*spdiag(w);
        idx   = find(abs(w)>THRESH);
        nfeat = length(idx);
		MODEL{i}.nfeat = nfeat;
        MODEL{i}.idx   = idx;
		MODEL{i}.w     = w;
		if(NORMALIZE)
		  MODEL{i}.mX    = mX(idx);
		  MODEL{i}.sX    = sX(idx);
		end;
		fprintf('Done with iteration:%d (active features:%d)\n',i,nfeat);
        if(nfeat < MIN_DIM)
        	 break;
		end;
    end;
	idx = MODEL{i}.idx;
	[tmp,idx]=sort(w,'descend');
    idx = idx(1:min(MIN_DIM,length(idx)));
%end function


