%function 
function [ftr,ftr_names,ver] = hsv_histogram(img)
    if(size(img,3)~=3)
      iimg = gray2ind(img,256);
      img  = ind2rgb(iimg,gray(256));
    end;
    %img = double(img);
    
    hsv = rgb2hsv(img);
    %get HSV channels
    H = hsv(:,:,1);
    S = hsv(:,:,2);
    V = hsv(:,:,3);
    %quantize the output 
    H=H(:); S=S(:);V=V(:);
    

    H   = floor(H*8);  H(H==8) = 7;
    S   = floor(S*8);  S(S==8) = 7;
    V   = floor(V/255.0*4); V(V==4) = 3;

    tcnt = length(H);
    %histogram
    freq = zeros(8*8*4,1);
    val  = H*32+S*4+V;

    for i = 0:255
      freq(i+1) = sum(val==i)/tcnt;
    end;
    
    %format the outputs
    ftr{1}       = freq(:);
    ftr_names{1} = 'HSV';
    ver          = 1;
  %end function

