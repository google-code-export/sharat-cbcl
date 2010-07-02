%------------------------------------------------------------------------------
%
%sharat@mit.edu
%------------------------------------------------------------------------------
clear all;
close all;
HOME='/data/scratch/sharat';
addpath(fullfile(HOME,'lgn'));
addpath(fullfile(HOME,'utils'));
addpath(fullfile(HOME,'ssdb'));
warning('off','all');
IMGHOME    = fullfile(HOME,'data','OT8');
FTRHOME    = fullfile(HOME,'data','OT8Features');
SPLITS     = [1];
SCALES     = [1 0.5 0.25];
%define parameters
idx = 1;
for size = [19,23,27,31,35]
  for N = [16,24,32,48,64]
    param(idx).size=size;
    param(idx).N   =N;
    idx = idx+1;
  end;
end;

for s=SPLITS
for p=1:length(param)
  split_file = fullfile(FTRHOME,sprintf('split_%03d',s));
  lock_file  = fullfile(FTRHOME,sprintf('train__%03d__%03d.lock',s,p));
  model_file = fullfile(FTRHOME,sprintf('model_%03d_%03d',s,p));
  if(exist(lock_file))
    fprintf('split %02d, param %02d, already exists\n',s,p);
    continue;
  end;
  save(lock_file','lock_file');
  load(split_file,'trn_set','tst_set','img_set');
  %get training images
  trn_set=trn_set{1};
  img_set=img_set(trn_set);
  
  for sidx=1:length(SCALES)
    fprintf('Processing split%d of %d, scale:%d\n',s,SPLITS,sidx);
    fprintf('Params:%d,%d\n',param(p).size,param(p).N);
    images = cell(length(img_set),1);
    for i=1:length(trn_set)
      fprintf('.');
      img       = imread(img_set{i});
      img       = im2double(rgb2gray(img));
      img       = imresize(img,[256 256]*SCALES(sidx),'bicubic');
      images{i} = conv2(img,fspecial('laplacian'),'valid');
    end;%i
    whos images
    model{sidx} = train_dictionary(images,param(p).size,...
	                           floor((param(p).size)/2),...
				   param(p).N,50);
  end;%sidx
  save(model_file,'model');
end;%p
end;%s
exit;
