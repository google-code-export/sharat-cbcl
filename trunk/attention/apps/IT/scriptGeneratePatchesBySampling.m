function patches=scriptGeneratePatchesBySampling(doSN,...
                                       c1Pool,...
                                       patchSize,...
                                       patchBand,...
                                       nPatches,...
                                       dSize)
load stock_image
load patches_gabor;
addpath('~/cbcl-model-matlab');
addpath('~/lgn');
addpath('~/cbcl-model-matlab')
load stock_image
load patches_gabor;
patches={};
%tst_img=cat(2,tst_img,trn_img);
for i=1:length(tst_img)
  img= im2double(tst_img{i});
  m  = mean(img(:));
  s  = std(img(:));
  img= (img-m)/(s+0.001);
  img= 1./(1+exp(-img));
  img= imresize(img,[75 75],'bicubic');
  img= imfilter(img,fspecial('gaussian'));
  c0 = create_c0(img,sqrt(sqrt(2)),4);
  s1 = s_norm_filter(c0,patches_gabor);
  if(doSN)
      s1 = s_dn(s1);
  end;      
  subplot(1,3,1);imagesc(vec2Color(s1{1}));axis image;
  c1 = c_local(s1,c1Pool,ceil(c1Pool/2),2,2);
  subplot(1,3,2);imagesc(vec2Color(c1{1}));axis image;
  drawnow;
  cimg=c1{patchBand};
  [cht,cwt,cdim]=size(cimg);
  pCount=0;
  pTrial=0;
  while(pTrial<200 & pCount<nPatches)
      cx   =ceil(cwt/2+dSize/8*randn);
      cy   =ceil(cht/2+dSize/8*randn);
      xpts =max(1,cx-floor(patchSize/2)):min(cwt,cx+floor(patchSize/2)); %assumes odd
      ypts =max(1,cy-floor(patchSize/2)):min(cht,cy+floor(patchSize/2));
      crop =cimg(ypts,xpts,:);
      cnorm=norm(crop(:));
      if(size(crop,1)>=patchSize & size(crop,2)>=patchSize & cnorm>=0.2)
         patches{end+1}=crop; 
         pCount=pCount+1;
         subplot(1,3,3);imagesc(vec2Color(crop));axis image;
         drawnow;
      else
         fprintf('*');
      end;
      pTrial=pTrial+1;
  end;
end;
