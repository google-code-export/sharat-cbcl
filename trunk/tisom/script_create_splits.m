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
IMG_HOME  = fullfile(HOME,'data','OT8');
TARGET    = fullfile(HOME,'data','OT8Features');
SPLITS    = 10;
FOLDS     = 2;
CVSET     = 200;
MAX_IMG   = inf;
EXTS      = {'jpg','JPG'};
for s=1:SPLITS
  	%split lock
  	split_file        = fullfile(TARGET,sprintf('split_%03d.mat',s));
 	[img_set,Y]       =read_all_images(IMG_HOME,EXTS,MAX_IMG);
	[tst_set,trn_set] =split_data(Y,FOLDS,1);
	cv_set={};
	for i=1:length(trn_set)
	  idx            = randperm(length(trn_set{i}));
	  idx            = idx(1:CVSET);
	  cv_set{i}      = trn_set{i}(idx);
	  trn_set{i}(idx)= [];
	end;
    save(split_file,'img_set','Y','tst_set','trn_set','cv_set');	
end; 
