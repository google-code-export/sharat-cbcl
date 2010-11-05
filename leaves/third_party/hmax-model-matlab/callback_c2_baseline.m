%--------------------------------------------------------
%callback_c2_baseline
%wrapper function to compute C1,C2,C2b layer output for an image
%paramters:
%    img: [IN] input image (grayscale)
%    c0patches: [IN] gabor patches
%    c1patches: [IN] shape prototypes
%    ftr: [OUT] cell array consisting of C1,C2,C2b outputs
%
%sharat@mit.edu
%------------------------------------------------------------
function ftr=callback_c2_baseline(img,c0patches,c1patches)
    if(size(img,3)==3)
      img = rgb2gray(img);
    end;
    img     = im2double(img);
    if(nargin<4)
        sigma = sqrt(1/2);
    end;
    %----------------------
    %
    %----------------------
    c0      =   create_c0(img,1.1133,12);
    s1      =   s_norm_filter(c0,c0patches);
    c1      =   c_local(s1,8,3,2,2);
    s2      =   s_grbf(c1,c1patches);
    c2      =   c_local(s2,8,3,2,2);
    c2b     =   c_global(s2);
    %format the outputs
    ftr{1}       = c1;
    ftr{2}       = c2;
    ftr{3}       = c2b;
    ftr_names{1} = {'c1','c2','c2b'};
    ver          = 1;
%end function

