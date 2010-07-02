%------------------------------------------------------------------------------
%
%
%sharat@mit.edu
%uses broadcast tag 70000
%-----------------------------------------------------------------------------
function [idx,MDL] = script_ftr_sel(X,y)
    addpath(genpath('/data/scratch/sharat/third_party/stprtool'));
    warning('off','all');
    NORMALIZE    = 0;
    MAX_ITER     = 15;
    THRESH       = 1e-4;
    MIN_DIM      = 1;
    GRID_SEARCH  = 0;
    if(~GRID_SEARCH)
      SVM_OPTIONS  = struct('verb',1,'bin_svm','smo','ker','linear','arg',[1],'C',[1]);
    else
      SVM_OPTIONS  = struct('solver','oaosvm','ker','linear','arg',[1],'C',logspace(-2,0,5),'num_folds',6,'solver_options',struct('bin_svm','smo','verb',1));
    end;
    if(NORMALIZE)
      mX         = mean(X,2);
      sX         = std(X,[],2);
      X          = X-repmat(mX,1,size(X,2));
      X          = spdiag(1./(sX+eps))*X;
    end;
    data         = struct('X',X,'y',y);
    for i = 1:MAX_ITER
        %---------------------------------
        %mpi stuff
        %---------------------------------
	if(~GRID_SEARCH)
	  model = oaosvm(data,SVM_OPTIONS);
	else
	  model = evalsvm(data,SVM_OPTIONS);
	end;
	w     = sum(abs(model.W),2);
        data.X= spdiag(w)*data.X;
        idx   = find(abs(w)>THRESH);
        nfeat = length(idx);

	MDL{i}.nfeat = nfeat;
        MDL{i}.idx   = idx;
	MDL{i}.w     = w;
	if(NORMALIZE)
	  MDL{i}.mX    = mX(idx);
	  MDL{i}.sX    = sX(idx);
	end;
        %----------------------------------
        %
        %----------------------------------
	model        = oaosvm(struct('X',X(idx,:),'y',y),model.options);
	yhat         = mvsvmclass(X(idx,:),model);
	MDL{i}.err   = mean(yhat~=y);
	MDL{i}.model = model;
	fprintf('Done with iteration:%d (active features:%d)\n',i,nfeat);
        if(nfeat < MIN_DIM)
             break;
	end;
	save('model_sel','model','MDL');   
    end;
    idx = MDL{i}.idx;
%end function


