%---------------------------------------------------
%create_c0
%creates and image pyramid 
%parameters:
% img   [IN] input image (grayscale)
% scale [IN] scale factor between adjacent levels in the pyramid
% levels[IN] number of levels in the pyramid
% c0    [IN] a cell array of size (levelsx1) containing the pyramid
%sharat@mit.edu
%-----------------------------------------------------
function c0=create_c0(img,scale,levels)
  if(isrgb(img))
    img=rgb2gray(img);
  end;
  if(~isfloat(img))
  	img = im2double(img);
  end;
  if(nargin<2)
    scale = 2^(1/4);%1.113;
    levels= 11;
  end;
  [ht,wt] =size(img);
  %preserve range
  pmin   = min(img(:));
  pmax   = max(img(:));
  prange = pmax-pmin+eps;
  c0{1}  = img;
  for i=1:levels-1
    out     =imresize(c0{i},round([ht,wt]*(scale^-i)),'bilinear');
    %new range
    nmax    =max(out(:));
    nmin    =min(out(:));
    nrange  =nmax-nmin+eps;
    out     =(out-nmin)/nrange*prange+pmin;
    c0{i+1} =out;
  end;
%end function
