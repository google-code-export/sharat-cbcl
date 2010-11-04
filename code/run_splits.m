%------------------------------------------------------------------------------
%
%sharat@mit.edu
%------------------------------------------------------------------------------
clear all;
close all;
HOME='/cbcl/cbcl01/sharat';
addpath(fullfile(HOME,'lgn'));
addpath(fullfile(HOME,'utils'));
addpath(fullfile(HOME,'java'));
warning('off','all');
FTR_HOME    = '/cbcl/scratch03/sharat';
FOLDERS     = {'AnimalFeaturesSOM'};
%IMG_HOME    = '/cbcl/scratch03/sharat/AnimalImages';
IMG_HOME    = '/cbcl/scratch02/serre/databases/AnimalAude/TestImages/Original/';
LOCK_SERVER    = 'borg-login-1.csail.mit.edu';
USE_LOCK_SERVER=0;
OBJ_SIZE       =[256 256]*1.5;

load('~/ssdb/patches_gabor','patches_gabor');
SPLITS    = [1:3];
for f = 1:length(FOLDERS)
TARGET = fullfile(FTR_HOME,FOLDERS{f});
if(~exist(TARGET))
  mkdir(TARGET);
end;
for s=SPLITS
  %split lock
  split_file = fullfile(TARGET,sprintf('split_%03d.mat',s));
  patch_file = fullfile(TARGET,sprintf('patch_som264_%03d.mat',s));
  load(split_file,'img_set','Y','tst_set','trn_set');		,
  trn_set = trn_set{1};
  tst_set = tst_set{1};
  load(patch_file,'patches');
  %------------------------------------------------
  %extract features for training set
  %------------------------------------------------
  rand('twister',sum(100*clock));
  for i=randperm(length(trn_set))
    fprintf('Training(%s,%d):%d of %d\n',TARGET,s,i,length(trn_set));
    file_lock = fullfile(TARGET,sprintf('trn_%03d_%03d.lock',s,i));
	file_ftr  = fullfile(TARGET,sprintf('trn_%03d_%03d.mat',s,i));
	if((~USE_LOCK_SERVER & exist(file_lock)) | (USE_LOCK_SERVER & query_lock(LOCK_SERVER,file_lock)))
		fprintf('File %d,%d under progress\n',s,i);
		continue;
    end;
	fprintf('Processing file %d,%d\n',s,i);
	if(~USE_LOCK_SERVER)
		save(file_lock,'file_lock');
	else
		insert_lock(LOCK_SERVER,file_lock);
	end;
	idx     = trn_set(i);
	lbl     = Y(idx);
	img_file= img_set{idx};[path,file,ext]=fileparts(img_file);
	img = imread(fullfile(IMG_HOME,[file ext]));
	size(img)
	img = imresize(img,OBJ_SIZE,'bicubic');
	ftr = callback_c2_baseline(img,patches_gabor,patches);
    save(file_ftr,'ftr','img_file','lbl'); clear ftr;pack;
  end;%end trn_set

  %------------------------------------------------
  %extract features for testing set
  %------------------------------------------------
  for i=randperm(length(tst_set))
    fprintf('Testing(%s,%d):%d of %d\n',TARGET,s,i,length(tst_set));
    file_lock = fullfile(TARGET,sprintf('tst_%03d_%03d.lock',s,i));
	file_ftr  = fullfile(TARGET,sprintf('tst_%03d_%03d.mat',s,i));
	if((~USE_LOCK_SERVER & exist(file_lock)) | (USE_LOCK_SERVER & query_lock(LOCK_SERVER,file_lock)))
		fprintf('File %d,%d under progress\n',s,i);
		continue;
    end;
	fprintf('Processing file %d,%d\n',s,i);
	if(~USE_LOCK_SERVER)
		save(file_lock,'file_lock');
	else
		insert_lock(LOCK_SERVER,file_lock);
	end;
	idx     = tst_set(i);
	lbl     = Y(idx);
	img_file= img_set{idx};[path,file,ext]=fileparts(img_file);
	img = imread(fullfile(IMG_HOME,[file ext]));
	img = imresize(img,OBJ_SIZE,'bicubic');
	ftr = callback_c2_baseline(img,patches_gabor,patches);
    save(file_ftr,'ftr','img_file','lbl');clear ftr;pack;
  end;%end tst_set 
end;%end split
end;%end folder
exit; 
