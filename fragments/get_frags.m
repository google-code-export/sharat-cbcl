%--------------------------------------------------------------------- 
%get_frags
% gets the fragments that are 'close' to the patch in the given
% image set
% usage:
%    frags = get_frags(patch,thresh,images)
%    patch - (IN) patch to be detected
%    thresh- (IN) threshold on the similarity score
% 
%sharat@mit.edu
%--------------------------------------------------------------------
function frags = get_frags(patch,thresh,images)
     dbg_flag  = 0; %you can turn this on if you want
     idx       = 1;
     frags     = [];
     for i     = 1:length(images)
          img       = images(i).img;
          [ht,wt]   = size(img);
	  [htp,wtp] = size(patch);
          cor       = corr_image(patch,img);
          [mi,mj]   = find(cor==max(max(cor)));
          mi = mi(1); mj = mj(1);
	  %check if out of bounds
          if((mi+htp-1 > ht) || (mj+wtp-1 > wt)) continue; end;
	  
	  score = (cor(mi,mj));
          if(score >= thresh) %detected
              blk            = img(mi:mi+htp-1,mj:mj+wtp-1);
	      %put the patch in context
	      img(mi:mi+htp-1,mj:mj+wtp-1) = patch;
	      if(dbg_flag)
                 imshow(img);pause;
	      end;
	      %record the fragment
	      frags(idx).con = img;
	      frags(idx).img = blk;
	      frags(idx).x   = mj;
	      frags(idx).y   = mi;
	      frags(idx).h   = htp;
	      frags(idx).w   = wtp;
	      idx            = idx+1;
	  end;
      end;
%end function get_frags






