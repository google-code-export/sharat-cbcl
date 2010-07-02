function [X,Y]=scriptGenerateTraining(patches,...
	                                 trnSize,...
                                     doSN,...
                                     c1Pool,...
                                     c2Pool)
addpath('~/lgn');
addpath('~/cbcl-model-matlab');
addpath('~/utils');

ftrHome='/cbcl/scratch04/sharat/gabriel/features';
imgHome='/cbcl/scratch04/sharat/gabriel';
load patches_gabor;
load stock_image tst_img tst_lbl
idx    = 1;
scales = logspace(log10(0.8),log10(1.25),16);
X      = [];
Y      = [];
for i=1:length(tst_img)
  for s=1:length(scales)
	fprintf('# %d,%d\n',i,s);
	img=tst_img{i};
    img=imresize(img,[trnSize trnSize],'bicubic');
	%img=img-mean(img(:));
	%img=img./std(img(:));
	%img=1./(1+exp(-img));
	img=imresize(img,scales(s),'bicubic');
	imagesc(img,[0 1]);axis image off;
	drawnow;
    ftr     =   callbackGabriel(img,patches_gabor,patches,c1Pool,c2Pool,doSN);
    c2b     =   ftr{3};
	X(idx,:)=   c2b(:)';
	Y(idx)  =   tst_lbl(i);
	idx     =   idx+1;
  end;
end;  

