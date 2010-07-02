%------------------------------------------------------
%get_corr_score
% computes the similarity matrix between the patches 
% and set of images. Each row corresponds to a patch
% and each column gives the response to a image
% usage:
% score = get_corr_score(patches,images)
% patches - (IN) a structure array (images are in .img)
% images  - (IN) a structure array (images are in .img)
% score   - (OUT) (npatch X nimages) size array
%         - score of 1 - very similar , 0 - not similar
%sharat@mit.edu
%-----------------------------------------------------
function score = get_corr_score(patches,images)
   dbg_flag = 0; %switch this on if you want
   nptch    = length(patches);
   nftr     = length(images);
   score    = zeros(nptch,nftr);
   for i = 1:nptch
     fprintf('corr_score:patch %d of %d\n',i,nptch);
     patch     = patches(i).img;
     for j = 1:nftr
       img        = double(images(j).img);
       cor        = corr_image(patch,img);
       if(dbg_flag)
	 imagesc(cor.*img); colormap('gray');pause;
       end;
       s          = max(max(cor)); 
       s          = s(1);
       score(i,j) = s;
       fprintf('.');
     end;
     fprintf('\n');
   end;
   if(dbg_flag)
     imagesc(score); pause;
   end;
%end function get_correlation_score



