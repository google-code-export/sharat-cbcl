%------------------------------------------------------------------------------
%
%sharat@mit.edu
%------------------------------------------------------------------------------
clear all;
close all;
%FTR_HOME='/cbcl/scratch03/sharat';
HOME='/cbcl/cbcl01/sharat';
LOCK_SERVER='borg-login-1.csail.mit.edu';
FTR_HOME='/cbcl/scratch04/sharat/data';

addpath(fullfile(HOME,'lgn'));
addpath(fullfile(HOME,'utils'));
addpath(fullfile(HOME,'ssdb'));
addpath(fullfile(HOME,'third_party','libsvm'));
addpath(fullfile(HOME,'java'));
warning('off','all');
DIRS      = {'CroppedAnimalFeaturesBG'};
SPLITS    = 2:3;
for dataset=1:length(DIRS)
  TARGET    = fullfile(FTR_HOME,DIRS{dataset});
	for s=SPLITS
		trn_lbl={};trn_acc={};trn_yhat={};
		tst_lbl={};tst_acc={};tst_yhat={};
		for t =0 
			FILE       = {'tst','trn'};
			split_file = fullfile(TARGET,sprintf('split_c2_%03d_%s.mat',s,FILE{t+1}));
			split_lock = fullfile(TARGET,sprintf('aggregate_%08d_%s.lock',s,FILE{t+1}));
			%if(query_lock(LOCK_SERVER,split_lock))
			if(exist(split_lock))
				fprintf('split %03d being run\n',s);
				%continue;
			end;
			%insert_lock(LOCK_SERVER,split_lock);
			save(split_lock,'split_lock');
			%---------------------------------	
			%training data
			%---------------------------------
			[X,Y,img_set]= aggregate_ftr(TARGET,s,t);
			%----------------------------------
			%write file
			%----------------------------------
	   		save(split_file,'X','Y','img_set');
		end;%t
	end;%s
end;%dataset
exit;
