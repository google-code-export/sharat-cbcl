%---------------------------------------------------------
%
%sharat@mit.edu
%
clear all;
close all;
HOME   ='/cbcl/cbcl01/sharat';
IMGHOME='/cbcl/scratch04/sharat/data/csailIO/csailIndoorOutdoor';
addpath(fullfile(HOME,'cbcl-model-matlab'));
addpath(fullfile(HOME,'lgn'));
addpath(fullfile(HOME,'utils'));
addpath(fullfile(HOME,'tisom'));
load patches_gabor; %has 11x11 gabor filters

imgdir=dir(fullfile(IMGHOME,'*.jpg'));
imgdir=imgdir(randperm(length(imgdir)));
c1Pool   =8;
patchBand=2;
doSN     =1;
patchSize=5;
dSize    =5;
nPatches =[4,4,4];

for c=1:3
for i=1:min(50,length(imgdir))
    img=imresize(imread(fullfile(IMGHOME,imgdir(i).name)),[256 340],'bicubic');
    lab= applycform(img,makecform('srgb2lab'));
    img= imfilter(lab(:,:,c),fspecial('gaussian'));
    c0 = create_c0(img,sqrt(sqrt(2)),4);
    s1 = s_norm_filter(c0,patches_gabor);
    if(doSN)
      s1 = s_dn(s1);
    end;      
    subplot(1,2,1);imagesc(vec2Color(s1{1}));axis image;
    c1 = c_local(s1,8,3,2,2);
    subplot(1,2,2);imagesc(vec2Color(c1{1}));axis image;
    drawnow;
    cimg{i}=c1{patchBand};
end;
model=train_dictionary(cimg,dSize,patchSize,nPatches(c),100);
for i=1:nPatches(c)^2
    patches{i}=model.filters{i};
end;
save(sprintf('patches_clustered_%d',c),'patches');
end;

