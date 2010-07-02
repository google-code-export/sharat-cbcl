clear all;
close all;
addpath(genpath('~/third_party/labelme'));
addpath(genpath('~/third_party/gist'));
DATA_HOME='/cbcl/scratch01/sharat/databases/CF/labelme';
GIST_HOME='/cbcl/scratch01/sharat/databases/CF/labelme/features/gist';
SIFT_HOME='/cbcl/scratch01/sharat/databases/CF/labelme/features/sift';
files=dir(fullfile(DATA_HOME,'images','*.jpg'));
% Parameters:
param.imageSize = 256;
param.orientationsPerScale = [8 8 4];
param.numberBlocks = 4;
param.fc_prefilt = 4;

SIFTparam.grid_spacing = 8; % distance between grid centers
SIFTparam.patch_size = 16; % size of patch from which to compute SIFT descriptor (it has to be a factor of 4)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CONSTANTS (you can not change this)
w = SIFTparam.patch_size/2; % boundary 

files=files(randperm(length(files)));
for f=1:length(files)
  infile=fullfile(DATA_HOME,'images',files(f).name);
  [path,name,ext]=fileparts(infile);
  lock_file=fullfile(DATA_HOME,'images',[name '.lock'])
  gist_file=fullfile(GIST_HOME,[name '.mat']);
  sift_file=fullfile(SIFT_HOME,[name '.mat']);
  
  if(exist(lock_file))
	fprintf('Skipping :%s\n',files(f).name);
	continue;
  end;
  save(lock_file,'lock_file');
  
  
  img=imread(infile);
  img=rgb2gray(img);
  fprintf('Processing file:%s\n',infile);
  % Computing gist:
  ftr=callback_gist(img);
  gist=ftr{1}(:);
  %[gist, param] = LMgist(img, '', param);
  % COMPUTE SIFT: the output is a matrix [nrows x ncols x 128]
  sift = LMdenseSift(img, '', SIFTparam); 

  save(gist_file,'gist','img');
  save(sift_file,'sift','SIFTparam','img');
 end;
  
