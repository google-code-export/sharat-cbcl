%--------------------------------------------------------------------------
%initialize_root
% initializes the root with the positive and non-class images. 
% usage:
%     root = initialize_root(pdir,ndir)
%     pdir - (IN) directory name containing positive images
%     ndir - (IN) directory name containing non-class images
% root is a nested structure than holds the whole fragment tree. 
% the different field in the structure are as follows:
%  img - fragment corresponding to the node. This field is
%        populated for each level of the tree except at the root
%  pos - an array with .img and .con fields. This array contains
%        the positive training examples. The img
%        contains the examples, while con contains the context in
%        which the patch (corresponding to .img) was detected. 
%  neg - an array with .img and .con fields. This array contains
%        negative training examples. 
%  w   - weights between the current node and its children
%  bias- bias of the node. 
%  h   - a structure array where each element is also a tree, with
%        the same structure. 
%  thresh-detection threshold for the patch 
%  roi - region of interest for the current patch.
%sharat@mit.edu
%--------------------------------------------------------------------------
function root = initialize_root(pdir,ndir)
    dbg_flag = 0;  %switch this off if you want
    root     = [];
    %load positive and negative images
    pfiles   = dir(sprintf('%s/*.jpg',pdir));
    nfiles   = dir(sprintf('%s/*.jpg',ndir)); 
    hmax     = 0;
    wmax     = 0;
    
    for i = 1:length(pfiles)
      root.pos(i).img = imread(sprintf('%s/%s',pdir,pfiles(i).name));
      [ht,wt]         = size(root.pos(i).img);
      hmax            = max(hmax,ht); 
      wmax            = max(wmax,wt);
      if(dbg_flag)
	imshow(root.pos(i).img),title(sprintf('Class image:%d',i));
	pause;
      end;
    end;

    for i = 1:length(nfiles)
      root.neg(i).img = imread(sprintf('%s/%s',ndir,nfiles(i).name));
      [ht,wt]         = size(root.neg(i).img);
      hmax            = max(hmax,ht);
      wmax            = max(wmax,wt);
      if(dbg_flag)
	imshow(root.neg(i).img),title(sprintf('Non-class image:%d',i));
	pause;
      end;
    end;
    
    %image 
    root.img    = zeros(hmax,wmax);
    root.thresh = 0;
    %children
    root.h      = [];
    %roi fields
    root.roi.x  = 1;
    root.roi.y  = 1;
    root.roi.h  = hmax;
    root.roi.w  = wmax;
    %classification fields
    root.w      = [];
    root.bias   = rand;
    %mi
    root.mi     = 0;
%end function
