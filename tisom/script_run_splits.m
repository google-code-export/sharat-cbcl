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
SPLITS     = 1;
PARAMS     = 1:25
SCALES     = [1 0.5 0.25];

for p=PARAMS
for s=SPLITS
  split_file = fullfile(FTRHOME,sprintf('split_%03d.mat',s));
  model_file = fullfile(FTRHOME,sprintf('model_%03d_%03d.mat',s,p))
  if(~exist(model_file))
    fprintf('model file %s not found!!\n',model_file);
    continue;
  end;
  load(split_file,'trn_set','tst_set','cv_set','img_set');
  load(model_file,'model');

  %get training images
  img_names=img_set(trn_set{1});
  for i=1:length(img_names)
    lock_file = fullfile(FTRHOME,sprintf('trn_%03d_%03d_%03d.lock',s,p,i));
    ftr_file  = fullfile(FTRHOME,sprintf('trn_%03d_%03d_%03d.mat',s,p,i));
    ftr       = [];
    if(exist(lock_file))
      fprintf('%s already exists\n',lock_file);
      continue;
    end;
    save(lock_file,'lock_file');
    fprintf('Processing train, split %d, %d of %d\n',s,i,length(img_names));
    for sidx=1:length(SCALES)
      fprintf('scale:%d\n',SCALES(sidx));
      img       = imread(img_names{i});
      img       = im2double(rgb2gray(img));
      img       = imresize(img,[256 256]*SCALES(sidx),'bicubic');
      img       = conv2(img,fspecial('laplacian'),'valid');
      [qout,res,dout]=quantize_domain(img,model{sidx});
      whos dout;
      ftr       = cat(1,ftr,dout(:));
    end;%sidx
    save(ftr_file,'ftr');
  end;%i
  
  %get testing images
  img_names=img_set(tst_set{1});
  for i=1:length(img_names)
    lock_file = fullfile(FTRHOME,sprintf('tst_%03d_%03d_%03d.lock',s,p,i));
    ftr_file  = fullfile(FTRHOME,sprintf('tst_%03d_%03d_%03d.mat',s,p,i));
    ftr       = [];
    if(exist(lock_file))
      fprintf('%s already exists\n',lock_file);
      continue;
    end;
    save(lock_file,'lock_file');
    fprintf('Processing test, split %d, %d of %d\n',s,i,length(img_names));
    for sidx=1:length(SCALES)
      fprintf('scale:%d\n',SCALES(sidx));
      img       = imread(img_names{i});
      img       = im2double(rgb2gray(img));
      img       = imresize(img,[256 256]*SCALES(sidx),'bicubic');
      img       = conv2(img,fspecial('laplacian'),'valid');
      [qout,res,dout]=quantize_domain(img,model{sidx});
      whos dout;
      ftr       = cat(1,ftr,dout(:));
    end;%sidx
    save(ftr_file,'ftr');
  end;%i

  %get cv images
  img_names=img_set(cv_set{1});
  for i=1:length(img_names)
    lock_file = fullfile(FTRHOME,sprintf('cv_%03d_%03d_%03d.lock',s,p,i));
    ftr_file  = fullfile(FTRHOME,sprintf('cv_%03d_%03d_%03d.mat',s,p,i));
    ftr       = [];
    if(exist(lock_file))
      fprintf('%s already exists\n',lock_file);
      continue;
    end;
    save(lock_file,'lock_file');
    fprintf('Processing cv, split %d, %d of %d\n',s,i,length(img_names));
    for sidx=1:length(SCALES)
      fprintf('scale:%d\n',SCALES(sidx));
      img       = imread(img_names{i});
      img       = im2double(rgb2gray(img));
      img       = imresize(img,[256 256]*SCALES(sidx),'bicubic');
      img       = conv2(img,fspecial('laplacian'),'valid');
      [qout,res,dout]=quantize_domain(img,model{sidx});
      whos dout;
      ftr       = cat(1,ftr,dout(:));
    end;%sidx
    save(ftr_file,'ftr');
  end;%i

end; %s
end;%p
exit;
