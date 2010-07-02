function patches=scriptGeneratePatches(tst_img,...
	                                   trnSize,...
                                       doSN,...
                                       c1Pool,...
                                       patchSize,...
                                       patchBand,...
                                       nPatches,...
                                       dSize)
load patches_gabor;
addpath('~/cbcl-model-matlab');
addpath('~/tisom');
for i=1:length(tst_img)
  img= im2double(tst_img{i});
  img= imresize(img,[trnSize trnSize],'bicubic');
  c0 = create_c0(img,sqrt(sqrt(2)),4);
  s1 = s_norm_filter(c0,patches_gabor);
  if(doSN)
      s1 = s_dn(s1);
  end;      
  subplot(1,2,1);imagesc(vec2Color(s1{1}));axis image;
  c1 = c_local(s1,c1Pool,ceil(c1Pool/2),2,2);
  subplot(1,2,2);imagesc(vec2Color(c1{1}));axis image;
  drawnow;
  cimg{i}=c1{patchBand};
end;
model=train_dictionary(cimg,dSize,patchSize,nPatches,100);
for i=1:length(model.filters(:))
  patches{i}=model.filters{i};
end;
for i=2:length(cimg)
  figure(1);imagesc(vec2Color(cimg{i}));
  figure(2);s=s_grbf({cimg{i}},patches);
  for j=1:length(patches)
	subplot(size(model.filters,1),size(model.filters,1),j);imagesc(s{1}(:,:,j),[0 1]);
  end;
end;
  

