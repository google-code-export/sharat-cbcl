%------------------------------------------------------------------------------
%
%
%sharat@mit.edu
%uses broadcast tag 70000
%-----------------------------------------------------------------------------
function [sel,th,alpha] = script_ftr_sel_adaboost(X,Y,MAX_FTR)
    if(nargin<3)
      MAX_FTR = 10;
    end;
    MAXDATA           = 3000; %per class
    Y                 = Y';
    LABELS            = unique(Y)
    sel               = [];
	th                = [];
	alpha             = [];
    %-------------------------------
    %reduce data points
    %-------------------------------
    for lbl = LABELS %assume last is background
      idx   = find(Y==lbl); 
      ridx  = randperm(length(idx));
      idx   = idx(ridx(1:min(length(ridx),MAXDATA)));
      sel   = union(sel,idx);
    end;
    X       = X(:,sel);
    Y       = Y(sel);
    %-------------------------------
    %do selection
    %-------------------------------
    [nftr,ndata]      = size(X)
    sel     = [];
    for lbl = LABELS(1:end-1) %assume last is background
    fprintf('Processing label-->%d\n',lbl);
    %-------------------------------
	%get count
	%-------------------------------
	pos               = sum(Y==lbl);
	neg               = sum(Y~=lbl);
	%-------------------------------
	%new labels
	%-------------------------------
	lblY              = Y;
	lblY(Y==lbl)      = 1;
	lblY(Y~=lbl)      = 2;
	%-------------------------------
	%new weights
	%-------------------------------
	D                 = ones(1,ndata);
	D(Y==lbl)         = 5*neg/(neg+pos);
	D(Y~=lbl)         = 1*pos/(neg+pos);
	D                 = D/sum(D);
	%-------------------------------
	%select features
	%------------------------------
	model = adaboost(struct('X',X,'y',lblY,'D',D),struct('weaklearner','fast_weaklearner','max_rules',MAX_FTR,'verb',1));
	for i = 1:length(model.rule)
	  sel = cat(1,sel,model.rule{i}.dim);
	  th  = cat(1,th,max(0,abs(model.rule{i}.b)-0.05));
	  alpha=cat(1,alpha,model.Alpha(i));
	end;
    end; %label
%end function
