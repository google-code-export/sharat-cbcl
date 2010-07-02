%----------------------------------------------------
%roi_mask
% creates a mask showing the roi
% usage: 
%   msk = roi_mask(ht,wt,roi)
%   ht  - (IN) height of the mask
%   wt  - (IN) width of the mask
%   roi - (IN) roi to visualize
%   msk - (OUT) output roi mask
%sharat@mit.edu
%----------------------------------------------------
function msk = roi_mask(ht,wt,roi)
    msk     = zeros(ht,wt);
    lx      = floor(roi.x);
    ly      = floor(roi.y);
    lh      = floor(roi.h);
    lw      = floor(roi.w);
    msk(max(1,ly):min(ly+lh-1,ht),max(1,lx):min(wt,lx+lw-1)) = 1;
%end function 
