%--------------------------------------------------------------------------
%script_generate_training
%----------
%parameters
%HOME- Image home. Each category should be in its own directory
%TRAINING_HOME- Feature home. The extracted features are stored here
%EXT - Extention of the image files. Specified as a cell array
%SCALES-unused
%IMG_SIZE - specifies size of the training images
%ENFORCE_SIZE - images not of the size IMG_SIZE are ignored.Set to 1 always
%SKIP         - step size for training images. Every SKIP image is used for training
%
%Notes:
% Note that this script can be called concurrently from multiple
% nodes to speed up extraction. Lock files are used to avoid 
% duplicate extraction from the same image file
%sharat@mit.edu
%--------------------------------------------------------------------------
clear all;
close all;
warning('off','all');
addpath(genpath('~/cbcl-model-matlab'));%change this

HOME         = '/cbcl/scratch01/sharat/databases/SSDBCrop';
%TRAINING_HOME= '/cbcl/scratch01/sharat/ssdb/C1_Training/SSDBCrop';
TRAINING_HOME= '/cbcl/scratch01/sharat/ssdb/C1_Training/SSDBCropNorm';
EXT          = {'JPG','jpg'};
MAX_FILES    = inf;
SCALES       = [];%logspace(log10(0.125),log10(1),16)*20;
IMG_SIZE     = [128 128];
ENFORCE_SIZE = 1;
SKIP         = 1;
%----------------------------------------
%setup callback arguments
%---------------------------------------
callback_fcn = 'callback_c1_baseline';
callback_fcn = 'callback_c1';
load('patches_gabor','patches_gabor');
callback_args= {patches_gabor,4};

%----------------------------------------
%start processing
%----------------------------------------
d = dir(HOME);
d = d(3:end);
if(~exist(TRAINING_HOME))
  mkdir(TRAINING_HOME);
end;

for i = 1:length(d),
  fprintf('%d--->%s\n',i,d(i).name);
  img_set=[];
  for e =1:length(EXT)
    img_set = cat(1,img_set,dir(fullfile(HOME,d(i).name,['*.' EXT{e}])));
  end;
  if(~strfind(d(i).name,'background'))
	img_set = img_set(1:min(MAX_FILES,length(img_set)));
  end;	
  for k=randperm(length(img_set))
     lock_file = fullfile(TRAINING_HOME,sprintf('%02d_%02d.lock',i,k-1));
     c1_file   = fullfile(TRAINING_HOME,sprintf('C1_%02d_%02d.mat',i,k-1));
     if(exist(lock_file))
       fprintf('%s exists\n',lock_file);
       continue;
     end;
     save(lock_file,'lock_file');
     fprintf('processing :%d of %d\n',k,length(img_set));
     img_file  = fullfile(HOME,d(i).name,img_set(k).name);
     img       = imread(img_file);
     if(ENFORCE_SIZE & (size(img,1)~=IMG_SIZE(1) | size(img,2)~=IMG_SIZE(2)))
       fprintf('Wrong size!!!!\n');
       continue;
     end;
     if(size(img,3)==3)
       img=rgb2gray(img);
     end;
     %----------------------------------------------------------
     %callback
     %----------------------------------------------------------
     RESIZE             = 0.75;
     img                = imresize(img,RESIZE,'bicubic');
     ftr                = feval(callback_fcn,img,callback_args{:});
     lbl                = i;
     org_img            = img;
     file_name          = img_set(k).name;
     save(c1_file,'ftr','lbl','org_img','file_name','RESIZE');
  end;
end
exit;

