%------------------------------------------------------------------------------
%
%sharat@mit.edu
%------------------------------------------------------------------------------
clear all;
close all;
HOME   ='/cbcl/cbcl01/sharat';
FTRHOME='/cbcl/scratch03/sharat';
addpath(fullfile(HOME,'lgn'));
addpath(fullfile(HOME,'utils'));
addpath(fullfile(HOME,'ssdb'));
warning('off','all');
IMG_HOME  = fullfile(FTRHOME,'Training');
TARGET    = fullfile(FTRHOME,'TrainingBG');
SPLITS    = 1:10;
FOLDS     = 9;
MAX_IMG   = inf;
EXTS      = {'jpg','JPG','pgm'};
for s=SPLITS
  	%split lock
  	split_file        = fullfile(TARGET,sprintf('split_%03d.mat',s));
 	[img_set,Y]       =read_all_images(IMG_HOME,EXTS,MAX_IMG);
	[tst_set,trn_set] =split_data(Y,FOLDS,1);
    save(split_file,'img_set','Y','tst_set','trn_set');	
end; 
