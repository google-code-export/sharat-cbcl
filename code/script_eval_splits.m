%------------------------------------------------------------------------------
%
%sharat@mit.edu
%------------------------------------------------------------------------------
clear all;
close all;
FEATURE_SELECTION=0;
FTR_HOME='/cbcl/scratch03/sharat';
HOME='/cbcl/cbcl01/sharat';
LOCK_SERVER='borg-login-1.csail.mit.edu';

addpath(fullfile(HOME,'lgn'));
addpath(fullfile(HOME,'utils'));
addpath(fullfile(HOME,'ssdb'));
addpath(genpath(fullfile(HOME,'ulmann')));
addpath(fullfile(HOME,'third_party','libsvm'));
addpath(genpath(fullfile(HOME,'third_party','stprtool')));
addpath(fullfile(HOME,'java'));
warning('off','all');
DIRS      = {'AnimalFeaturesSOM'};%{'PNASFeatures'};
%{'AnimalFeaturesBG'};%,'MaskedAnimalFeaturesPosition','MaskedAnimalFeatures'};
sel       = [];
for dataset=1:length(DIRS)
	TARGET    = fullfile(FTR_HOME,DIRS{dataset});
	SPLITS    = 1;
	try
	for s=randperm(SPLITS)
	    trn_lbl={};trn_acc={};trn_yhat={};
		tst_lbl={};tst_acc={};tst_yhat={};
		trn_file = fullfile(TARGET,sprintf('split_c2_%03d_trn.mat',s));
		tst_file = fullfile(TARGET,sprintf('split_c2_%03d_tst.mat',s));
		split_file=fullfile(TARGET,sprintf('split_c2_%03d_results.mat',s));
		split_lock = fullfile(TARGET,sprintf('evaluate_%03d.lock',s));
		if(~exist(trn_file) )
			fprintf('Did not find %s\n!!!',trn_file);
			continue;
		end;
		if(~exist(tst_file))
			fprintf('Did not find%s\n!!!',tst_file);
			continue;
		end;
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
		load(trn_file,'X','Y','img_set');
		trnX=X(:,1:1000);trnY=Y;trn_set=[];%img_set;	
		clear X; clear Y;
		%-----------------------------------
		%testing
		%-----------------------------------
		load(tst_file,'X','Y','img_set');
		tstX=X(:,1:1000);tstY=Y;tst_set=img_set;
		clear X; clear Y;
		%-----------------------------------
		%sparsify
		%-----------------------------------
		if(1)
		  mX    = mean(trnX);
		  sX    = std(trnX)+0.01;
		  trnX  = (trnX-repmat(mX,size(trnX,1),1))*spdiag(1./sX);trnX=1./(1+exp(-trnX));
		  tstX  = (tstX-repmat(mX,size(tstX,1),1))*spdiag(1./sX);tstX=1./(1+exp(-tstX));
		end;  
		%-------------------------------
		%feature selection
		%-------------------------------
		if(FEATURE_SELECTION)
			sel = script_ftr_sel_mi(trnX',trnY,6000);
			trnX= trnX(:,sel);
			tstX= tstX(:,sel);
		end;
		%----------------------------------
		%train svm
		%----------------------------------
		lbl   = unique(trnY);
		if(lbl(end)==2) %binary!!
			trnY  = remap(trnY,{[0 1],[2]},[1 -1]);
			tstY  = remap(tstY,{[0 1],[2]},[1 -1]);
		end;
		trial = 1;
		for c = logspace(-3,1,8)
			%for g = logspace(-3,1,4)
			model = svmtrain(trnY,trnX,sprintf('-t 0 -c %f',c));
			[trn_lbl{trial},trn_acc{trial},trn_yhat{trial}]=svmpredict(trnY,trnX,model);
			[tst_lbl{trial},tst_acc{trial},tst_yhat{trial}]=svmpredict(tstY,tstX,model);
			clear model;
			trial = trial+1;
			%end;
	   end;
	   save(split_file,'trn_lbl','tst_lbl','trn_acc','tst_acc','trn_yhat','tst_yhat','trnY','tstY',...
	   				   'trnX','trnY','tstX','tstY','sel','trn_set','tst_set');
	end;
	catch
		err = lasterror
		fprintf('Error!!!!%s\n');
		keyboard;
		continue;
	end;
end;
%exit;
