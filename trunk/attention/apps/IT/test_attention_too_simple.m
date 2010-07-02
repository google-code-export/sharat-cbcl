clear all;
close all;
load stock_image
load patches_gabor;
tst_img=cat(2,tst_img,trn_img);
for i=1:length(tst_img)
  img= im2double(tst_img{i});
  m  = mean(img(:));
  s  = std(img(:));
  img= (img-m)/(s+0.001);
  img= 1./(1+exp(-img));
  img= imresize(img,[75 75],'bicubic');
  img= imfilter(img,fspecial('gaussian'));
  tst_img{i}=img;
end;
nLeves=4;
[patches,retband,retx,rety,retsz]=get_c_patches(tst_img,patches_gabor,nLevels);
for i=1:length(tst_img)
    ftr=callback_c1_baseline(tst_img{i},patches_gabor,nLevels)
    cimg{i}=ftr{2};
end;

for i=2:length(cimg)
  figure(1);imagesc(vec2Color(cimg{i}));
  figure(2);s=s_grbf(cimg{i},patches);
  for j=1:length(patches)
	subplot(size(model.filters,1),size(model.filters,1),j);imagesc(s{1}(:,:,j),[0 1]);
  end;
  pause;
end;
  

