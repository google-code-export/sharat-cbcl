%-----------------------------------------------------------------------
%get_optimal_roi
% assigns optimal roi to each node in the heirarchy so as to
% maximize mutual information
% usage:
%       root = get_optimal_roi(root)
%       root - IN/OUT the root must be initialized using 
%              get_fragment_hierarchy.m before calling this function
%sharat@mit.edu
%-----------------------------------------------------------------------
function root = get_optimal_roi(root,varargin)
    dbg_flag = 0; %you can turn this on if you want
    if(isempty(root.h))
        return;
    end;
    if(isempty(varargin)) varargin{1} = 0; end; %depth  
    [ht,wt] = size(root.img);  
    for i = 1:length(root.h)
        fprintf('ROI (Depth:%d)-(Child %d of %d)\n',varargin{1},i,length(root.h));
        root.h(i).roi   = best_roi(root,root.h(i));
	if(dbg_flag)%show the roi
	  msk = roi_mask(ht,wt,root.h(i).roi);
	  subplot(1,2,1),imshow(root.h(i).img);
	  subplot(1,2,2),imshow(msk);
	  pause;
	end;
    root.h(i)       = get_optimal_roi(root.h(i),varargin{1}+1);
    end;
%end

%------------------------------------------------------------
% best_roi
% helper function
%------------------------------------------------------------
function roi = best_roi(root,rh)
    patch       = rh.img;
    [hmax,wmax] = size(root.img);
    [htp,wtp]   = size(patch);
    maxmi       = -1;
    %get responses
    for i = 1:length(root.pos)
      pres(i).img = corr_image(patch,root.pos(i).img);
    end;

    for i = 1:length(root.neg)
      nres(i).img = corr_image(patch,root.neg(i).img);
    end;
    
    xc        = floor(rh.roi.x);
    yc        = floor(rh.roi.y);
    
    roi       = rh.roi;
    %expand default roi
    %roi.x     = max(1,floor(roi.x-roi.w/2));
    %roi.y     = max(1,floor(roi.y-roi.h/2));
    %roi.h     = min(roi.h*2,0.6*hmax);
    %roi.w     = min(roi.w*2,0.6*wmax);
    %optimize roi 
    for h = 0:4:floor(0.65*hmax)     
         for w=0:4:floor(0.65*wmax)
            %check positive images
            pscore = roi_scores(pres,xc,yc,h,w);
            nscore = roi_scores(nres,xc,yc,h,w);
            %discretize scores
            pscore = (pscore >= rh.thresh);
            nscore = (nscore >= rh.thresh);
            %compute mutual information
            hx     = entropy([pscore,nscore],[0,1]);
            hx_1   = entropy(pscore,[0,1]);
            hx_0   = entropy(nscore,[0,1]);
            p1     = length(pscore)/(length(pscore)+length(nscore));
            p0     = 1-p1;
            mi     = hx-(p0*hx_0+p1*hx_1);
            if(mi > maxmi)
                maxmi = mi;
                roi.x = floor(max(xc-w/2,1)); roi.w = floor(w);
                roi.y = floor(max(yc-h/2,1)); roi.h = floor(h);
	    end;
	    fprintf('.');  
        end;
     end;
     fprintf('\n'); 
%end function best_roi

%----------------------------------------------
%roi_scores
%helper function
%----------------------------------------------
function s     = roi_scores(res,xc,yc,h,w)
     for i = 1:length(res)
           img     = res(i).img;
           [ht,wt] = size(img);
           lx  = floor((xc-w/2));
           ly  = floor((yc-h/2));
           img = img(max(ly,1):min(ly+h-1,ht),max(lx,1):min(lx+w-1,wt));
           if(isempty(img))
    	     s(i) = -1;
            continue;
            end;
    	   r   = max(max(img));
           s(i)= r(1);
     end;
%end function roi_scores

