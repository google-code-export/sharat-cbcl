%-------------------------------------------------------
%corr_image
%sharat@mit.edu
%-------------------------------------------------------
function cor = corr_image(patch,image)
  dog_flag   = 0;
  multi_res  = 0;
  [ht,wt]    = size(image);
  [htp,wtp]  = size(patch);
  cor        = zeros(ht,wt);
  %check terminal cond
  if(htp > ht || wtp > wt) return; end;
  %check DoG filter
  if(dog_flag)
    patch    = dog_filter(patch);
    image    = dog_filter(image);
  else
    patch    = double(patch);
    image    = double(image);
  end;
  patch      = patch+eps*rand(size(patch)); %avoid errors
  if(is_blank(patch)) return; end;
  cor        = normxcorr2(patch,image);
  cor        = cor(htp:end,wtp:end);
%end function

%------------------------------------
%
%-----------------------------------
function res = dog_filter(img)
    hsmall = fspecial('gaussian',[5 5],1.5);
    hbig   = fspecial('gaussian',[9 9],3);
    res    = imfilter(img,hbig,'same')-imfilter(img,hsmall,'same');
%end

%------------------------------------
%
%------------------------------------
function res = is_blank(patch)
  res = 0;
  if(std(double(patch(:)))<2)
    res = 1;
  end;
%end
