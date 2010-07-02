%---------------------------------------------------------
%
%sharat@mit.edu
%
clear all;
close all;
HOME   ='/cbcl/cbcl01/sharat';
IMGHOME='/cbcl/scratch04/sharat/data/csailIndoorOutdoor';
addpath(fullfile(HOME,'cbcl-model-matlab'));
addpath(fullfile(HOME,'lgn'));
imgdir=dir(fullfile(IMGHOME,'*.jpg'));
imgdir=imgdir(randperm(length(imgdir)));
for i=1:min(100,length(imgdir))
    img_set{i}=imresize(imread(fullfile(IMGHOME,imgdir(i).name)),[256 340],'bicubic');
end;
load patches_gabor; %has 11x11 gabor filters
patches = get_c_patches(img_set,[1],[8 12],'callback_c1_baseline',patches_gabor);
save patches_aim patches
