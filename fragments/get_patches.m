%--------------------------------------------------------------------------
%get_patches
%  retrieves random patches from the image set. The patch size
%  ranges from from 1/10 to 1/2  the image size.
%  usage: 
%      patches = get_patches(img_set,N)
%      img_set - (IN)  a structure array (with image in .img field)
%      N       - (IN)  maximum number of patches to be extracted.
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
function patches = get_patches(pos,N,MAX_IMAGES)
     %create an exhaustive patch list
     dbg_flag   =   0; %switch this on if you like
     imgid      =   1;
     patchloc   =   [];
     patches    =   [];
     pnum       =   1;
     for i=1:min(length(pos),MAX_IMAGES)
         %change scales
         org_img               =   pos(i).img;
         fprintf('get_patches: processing %d of %d\n',i,length(pos));
         for scale             =   [1];
            img                =   imresize(org_img,scale);
            images(imgid).img  =   img;
            [ht,wt]            =   size(img);
             %change sizes
             for patch_ht = [48 32 24 16 12 8] %unique(floor(ht*0.1*(1.5.^[0:5]))) %0.1 to 0.5
                if(patch_ht<8);continue;end;          %ignore small patches
                for patch_wt = [48 32 24 16 12 8] %unique(floor(wt*0.1*(1.5.^[0:5])))
                    hstep = floor(0.3*patch_ht);
                    wstep = floor(0.3*patch_wt);
                    %generate patches
                    if(patch_wt<8) continue; end;     %ignore small patches       
                    for row = 1:hstep:ht-patch_ht+1
                        for col=1:wstep:wt-patch_wt+1
                            patchloc(pnum,:) = [imgid,row,row+patch_ht-1,col,col+patch_wt-1];
                            pnum             = pnum+1;
                        end; %col
                    end;%row--1
                 end;%patch_wt
	       end;%patch_ht
	       imgid = imgid+1;
         end;%scale
     end;%i
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

