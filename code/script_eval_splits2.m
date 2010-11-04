%------------------------------------------------------------------------------
%
%sharat@mit.edu
%------------------------------------------------------------------------------
clear all;
close all;
FEATURE_SELECTION=0;
NORMALIZE        =0;
%FTR_HOME='/cbcl/scratch03/sharat/PNAS';
FTR_HOME='/cbcl/scratch03/sharat';
HOME='/cbcl/cbcl01/sharat';
LOCK_SERVER='borg-login-1.csail.mit.edu';

addpath(fullfile(HOME,'lgn'));
addpath(fullfile(HOME,'utils'));
addpath(fullfile(HOME,'ssdb'));
addpath(genpath(fullfile(HOME,'ulmann')));
addpath(fullfile(HOME,'third_party','libsvm'));
addpath(fullfile(HOME,'third_party','classif'));
addpath(genpath(fullfile(HOME,'third_party','stprtool')));
addpath(fullfile(HOME,'java'));
warning('off','all');
%DIRS      = {'PNASFeatures'};
%DIRS      = {'Baseline'};
DIRS = {'AnimalFeaturesBG'};
SPLITS    = 1;
MAXFTR    = 6000;
sel       = [];
for dataset=1:length(DIRS)
	TARGET    = fullfile(FTR_HOME,DIRS{dataset});
	try
	for s=randperm(SPLITS)
	    trn_lbl={};trn_acc={};trn_yhat={};
		tst_lbl={};tst_acc={};tst_yhat={};
		trn_file = fullfile(TARGET,sprintf('split_c2_%03d_trn.mat',s));
		tst_file = fullfile(TARGET,sprintf('split_c2_%03d_tst.mat',s));
		split_file=fullfile(TARGET,sprintf('split_c2_%03d_results.mat',s));
		split_lock = fullfile(TARGET,sprintf('evaluate_%03d.lock',s));
		model_file = fullfile(TARGET,sprintf('classif_%03d.mat',s));
		if(~exist(trn_file) )
			fprintf('Did not find %s!!!\n',trn_file);
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
		IDX=3001:7172;%17172; %randperm(size(X,2));IDX=IDX(1:6000);
		trnX=X(:,IDX);trnY=Y;trn_set=img_set;	
		clear X; clear Y;
		whos trnX
		%-----------------------------------
		%testing
		%-----------------------------------
		load(tst_file,'X','Y','img_set');
		tstX=X(:,IDX);tstY=Y;tst_set=img_set;
		clear X; clear Y;
		%------------------------------------
		%load model if it exists
		if(exist(model_file))
		  fprintf('Model found\n');
		  load(model_file,'model');
		else
		  fprintf('Will generate model\n');
		  model=[];
		end;
		%-----------------------------------
		%sparsify
		%-----------------------------------
		if(NORMALIZE)
		  mX    = mean(trnX);
		  sX    = std(trnX)+0.01;
		  trnX  = (trnX-repmat(mX,size(trnX,1),1))*spdiag(1./sX);trnX=1./(1+exp(-trnX));
		  tstX  = (tstX-repmat(mX,size(tstX,1),1))*spdiag(1./sX);tstX=1./(1+exp(-tstX));
		end;
		%-------------------------------
		%feature selection
		%-------------------------------
		if(FEATURE_SELECTION)
			sel = script_ftr_sel_mi(trnX',trnY,MAXFTR);
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
		if(isempty(model))  
		  model 		  = cvLeastSquareRegu(trnX',trnY);
		end;
		trn_yhat{1}	  = LeastSquareReguC(trnX',model);
		tst_yhat{1}   = LeastSquareReguC(tstX',model);
	    trn_lbl{1}    = sign(trn_yhat{1})';
		tst_lbl{1}    = sign(tst_yhat{1})';
		trn_acc{1}    = mean(trn_lbl{1}==trnY);
		tst_acc{1}    = mean(tst_lbl{1}==tstY);	
		fprintf('Training accuracy:%f\n',trn_acc{1});
		fprintf('Testing accuracy:%f\n',tst_acc{1});	
	   save(split_file,'trn_lbl','tst_lbl','trn_acc','tst_acc',...
		   'trn_yhat','tst_yhat','trnY','tstY',...
	   		'trnX','trnY','tstX','tstY','sel','trn_set','tst_set');
	   save(model_file,'model');
	end;
	catch
		err = lasterror
		fprintf('Error!!!!%s\n');
		keyboard;
		continue;
	end;
end;
%exit;
