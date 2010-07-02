%------------------------------------------------------------------------------
%
%
%sharat@mit.edu
%uses broadcast tag 70000
%-----------------------------------------------------------------------------
function [sel,th,mi,minf] = script_ftr_sel_mi(X,Y,MAX_FTR)
    addpath(genpath('/data/scratch/sharat/ulmann'));
    if(nargin<3)
      MAX_FTR = 20;
    end;
    LABELS            = unique(Y');
    sel               = [];
    th                = [];
    minf              = [];
	mi                = [];
    for lbl = LABELS(1:end-1) %assume last is background
      %-------------------------------
      %select features
      %-------------------------------
      pos               = X(:,Y==lbl);
      neg               = X(:,Y~=lbl); 
      if(size(pos,2)<size(neg,2))
		pos               = repmat(pos,1,ceil(size(neg,2)/size(pos,2)));
      else
		neg               = repmat(neg,1,ceil(size(pos,2)/size(neg,2)));
      end;
      [thresh,tmi]     = get_thresh_mi(pos,neg);
      [idx,dmi]        = get_best_patches(pos,neg,thresh,tmi,MAX_FTR);
      %[dmi,idx]        = sort(tmi,'descend');
	  if(length(idx)>MAX_FTR)
		idx = idx(1:MAX_FTR);
	  end;
      sel              = cat(2,sel,idx);
      th               = cat(2,th,thresh(idx));
      minf             = cat(2,minf,dmi);
	  mi               = cat(2,mi,tmi(idx));
    end; %label
    for i=1:length(sel)
      fprintf('%d,%f,%f\n',i,th(i),minf(i));
    end;
%end function
