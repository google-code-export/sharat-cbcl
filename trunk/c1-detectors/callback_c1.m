%--------------------------------------------------------
%callback_c1_baseline
%wrapper function to compute C1 layer output for an image
%paramters:
%    img: [IN] input image (grayscale)
%    c0patches: [IN] gabor patches
%    nLevel: [IN] number of levels in the C0 image pyramid
%    ftr: [OUT] cell array consisting of S1,C1 scale pyramid
%
%sharat@mit.edu
%------------------------------------------------------------
function ftr=callback_c1(img,c0patches,nLevels)
    if(size(img,3)==3)
      img = rgb2gray(img);
    end;
    img     = im2double(img);
	img     = imfilter(img,fspecial('gaussian'),'same');
    if(nargin<3)
        nLevels=16;
    end;
    %----------------------
    %
    %----------------------
    c0      =   create_c0(img,1.1133,nLevels);
	for i=1:length(c0)
	  c0{i}=normalize_image(c0{i});
	end;  
    s1      =   s_norm_filter(c0,c0patches);
    psz     =   size(c0patches{1},1);
    c1      =   c_local(s1,psz,ceil(psz/2),2,2);
    %format the outputs
    ftr{1}       = s1;
    ftr{2}       = c1;
    ftr_names{1} = {'S1','C1'};
    ver          = 1;
%end function

function out=normalize_image(img)
   num=conv2(img,fspecial('laplacian'),'same');
   den=conv2(ones(3,1),ones(3,1),num.^2,'same');
   out=num./max(sqrt(den),0.1);
%end function
