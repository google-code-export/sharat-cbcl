%-------------------------------------------------------
%
%sharat@mit.edu
function ftr=callback_hist_leaves(img,varargin);
    %out         = preprocess(img);
    %[out,shape] = cleanup(img);
    c0Patches= gabor_patches(15, 8);
    [ht,wt,ndim]= size(img);
    img         = rescaleHeight(img,800);
    ftr         = callback_c1_leaves(img,c0Patches);
		keyboard;
    c1          = ftr{2};clear ftr;
    c1b = [];
    for b=1:length(c1)
        chist=c_hist(c1(b),4,3);
    	for x=1:3
	      for y=1:4
	        currHist=squeeze(chist{1}(y,x,:));
    	    currHist=currHist;%/sum(currHist);
	        c1b = cat(1,c1b,currHist);
    	  end;
	    end;
    end;
    ftr=[c1b(:)];
%

