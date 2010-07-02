%--------------------------------------------------------------------------
%get_fixed_size_patches
%  retrieves patches of a fixed size from a regular grid. 
%  usage: 
%      patches = get_patches(img_set,N)
%      img_set - (IN)    a structure array (with image in .img field)
%      N       - (IN)    size of the patches to be extracted
%      M       - (IN:opt)maximum number of images to sample
%      patches - (OUT) a structure array (with image in .img field)
%
%     patches
%       .x  
%       .y     - co-ordinates from where they were extracted
%       .img   - image of the patch
%       .h     
%       .w     - size of the patch

%sharat@mit.edu
%--------------------------------------------------------------------------
function patches = get_fixed_size_patches(pos,N,M,varargin)
     %create an exhaustive patch list
     dbg_flag   =   0; %switch this on if you like
     imgid      =   1;
     patchloc   =   [];
     patches    =   [];
     step_size  =   8; %step sizes
     blk_size   =   32;%size of patches
     pnum       =   1;
     
     if(~isempty(varargin))
       step_size = step_size/(2^(varargin{1}));
       blk_size  = blk_size/(2^(varargin{1}));
     end;
     for i=1:min(M,length(pos))
         %---------------
         %change scales
	 %---------------
         org_img               =   pos(i).img;
         fprintf('get_patches: processing %d of %d\n',i,length(pos));
         for scale             =   [1];
            img                =   imresize(org_img,scale);
            images(imgid).img  =   img;
            [ht,wt]            =   size(img);
	     %-------------------
             %change sizes
	     %-------------------
             for hsize = [blk_size]
                for wsize = [blk_size] 
                    for row = 1:step_size:ht-hsize+1
                        for col=1:step_size:wt-wsize+1
                            patchloc(pnum,:) = [imgid,row,row+hsize-1,col,col+wsize-1];
                            pnum             = pnum+1;
                        end; %col
                    end;%row
                 end;%wsize
	       end;%hsize
	       imgid = imgid+1;
         end;%scale
     end;
     %select at most N patches randomly
     patchloc   =   prune_list(patchloc,N);
     %extract actual image regions
     for i = 1:size(patchloc,1)
        img            = images(patchloc(i,1)).img;
        c              = patchloc(i,2:end);
        patches(i).img = img(c(1):c(2),c(3):c(4));
	patches(i).x   = c(3);
	patches(i).y   = c(1);
	patches(i).w   = c(4)-c(3)+1;
	patches(i).h   = c(2)-c(1)+1;
      end;
    if(dbg_flag)
       for i = 1:length(patches)
	  imshow(patches(i).img); pause;
       end;
    end;
%end function 


%-------------------------------------------------------------------------
%prune_list
%
%sharat@mit.edu
%-------------------------------------------------------------------------
function rec = prune_list(rec,N)
    %check if we need to prune
    if(isempty(rec) || size(rec,1)<N)
        return;
    end;
    %mix it up first
    [y,idx]          = sort(rand(1,size(rec,1)));
    rec              = rec(idx,:);
    %select candidates
    rec              = rec(1:N,:);
    %sort according to id
    [y,idx]          = sort(rec(:,1));
    rec              = rec(idx,:);
%end function create_random_patch_list
