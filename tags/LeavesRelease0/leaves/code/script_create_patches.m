%------------------------------------------------------------------------------
%
%sharat@mit.edu
%------------------------------------------------------------------------------
clear all;
close all;
HOME='/data/scratch/sharat';
LOCK_SERVER='borg-login-1.csail.mit.edu';
addpath(fullfile(HOME,'lgn'));
addpath(fullfile(HOME,'utils'));
addpath(fullfile(HOME,'ssdb'));
addpath(fullfile(HOME,'java'));
warning('off','all');
FTR_HOME  = fullfile(HOME,'data');
FOLDERS   = {'AnimalFeatures'};
SPLITS    = 5;
LEAVE_BACKGROUND=1;
MAX_IMG   = inf;
EXTS      = {'jpg','JPG'};
BANDS     = [1:4];
load('patches_gabor','patches_gabor');
VARARGIN  = {patches_gabor};
for f=1:length(FOLDERS)
TARGET=fullfile(FTR_HOME,FOLDERS{f})
for s=1:SPLITS
  %split lock
  split_lock = fullfile(TARGET,sprintf('patch_%03d.lock',s));
  split_file = fullfile(TARGET,sprintf('split_%03d.mat',s));
  patch_file = fullfile(TARGET,sprintf('patch_%03d.mat',s));
  if(query_lock(LOCK_SERVER,split_lock))
    fprintf('Split %d under progress\n',s);
    continue;
  end;
  insert_lock(LOCK_SERVER,split_lock);
  save(split_lock,'split_lock');
  load(split_file,'img_set','Y','tst_set','trn_set');		,
  trn_set = trn_set{1};
  tst_set = tst_set{1};
  if(LEAVE_BACKGROUND)
  	lbl    = unique(Y)';
	fprintf('Unique labels:%d',lbl);
	pause(10);
  	idx    = find(Y(trn_set)~=lbl(end));
	trn_set= trn_set(idx);
	idx    = find(Y(tst_set)~=lbl(end));
	tst_set= tst_set(idx);
  end;
  [patches_c1,bands_c1] = get_c_patches(img_set(trn_set),...
                          BANDS,'callback_c1_baseline',VARARGIN{:});
  save(patch_file,'patches_c1','bands_c1');
end;%split
end;%folders

exit;
 
