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
IMG_HOME  = fullfile(HOME,'data','leaves');
TARGET    = fullfile(HOME,'data','lgn-leaves-features');
SPLITS    = 10;
MAX_IMG   = inf;
EXTS      = {'jpg','JPG'};
for s=randperm(SPLITS)
  %split lock
  split_file = fullfile(TARGET,sprintf('split_%03d.mat',s));
  patch_file = fullfile(TARGET,sprintf('patch_%03d.mat',s));
  load(split_file,'img_set','Y','tst_set','trn_set');		,
  trn_set = trn_set{1};
  tst_set = tst_set{1};
  load(patch_file,'patches_c1','bands_c1');
  %------------------------------------------------
  %extract features for training set
  %------------------------------------------------
  for i=randperm(length(trn_set))
    fprintf('Training:%d of %d\n',i,length(trn_set));
    file_lock = fullfile(TARGET,sprintf('trn_%03d_%03d.lock',s,i));
	file_ftr  = fullfile(TARGET,sprintf('trn_%03d_%03d.mat',s,i));
	if(exist(file_lock))
		fprintf('File %d,%d under progress',s,i);
		continue;
    end;
	save(file_lock,'file_lock');
	idx     = trn_set(i);
	lbl     = Y(idx);
	img_file= img_set{idx};
	img = imread(img_file);
	ftr = callback_c2_gd2D(img,patches_c1);
    save(file_ftr,'ftr','img_file','lbl');
  end;%end trn_set

  %------------------------------------------------
  %extract features for training set
  %------------------------------------------------
  for i=randperm(length(tst_set))
    fprintf('Testing:%d of %d\n',i,length(tst_set));
    file_lock = fullfile(TARGET,sprintf('tst_%03d_%03d.lock',s,i));
	file_ftr  = fullfile(TARGET,sprintf('tst_%03d_%03d.mat',s,i));
	if(exist(file_lock))
		fprintf('File %d,%d under progress',s,i);
		continue;
    end;
	save(file_lock,'file_lock');
	idx     = tst_set(i);
	lbl     = Y(idx);
	img_file= img_set{idx};
	img = imread(img_file);
	ftr = callback_c2_gd2D(img,patches_c1);
    save(file_ftr,'ftr','img_file','lbl');
  end;%end tst_set
end;%end split
exit; 
