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
function ftr=callback_c1_baseline(img,c0patches,nLevels)
    if(size(img,3)==3)
      img = rgb2gray(img);
    end;
    img     = im2double(img);
    if(nargin<3)
        nLevels=16;
    end;
    %----------------------
    %
    %----------------------
    c0      =   create_c0(img,1.1133,nLevels);
    s1      =   s_norm_filter(c0,c0patches);
    psz     =   size(c0patches{1},1);
    c1      =   c_local(s1,psz,ceil(psz/2),2,2);
    %format the outputs
    ftr{1}       = s1;
    ftr{2}       = c1;
    ftr_names{1} = {'S1','C1'};
    ver          = 1;
%end function

