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
addpath(fullfile(HOME,'third_party','libsvm'));
warning('off','all');
DIRS      = {'leaves-ftr','lgn-leaves-features','lgn-sparse-features'};
for dataset=1:length(DIRS)
	TARGET    = fullfile(HOME,'data',DIRS{dataset});
	SPLITS    = 10;
	trn_lbl={};trn_acc={};trn_yhat={};
	tst_lbl={};tst_acc={};tst_yhat={};
	for s=randperm(SPLITS)
		split_file = fullfile(TARGET,sprintf('split_c2_%03d_results.mat',s));
		split_lock = fullfile(TARGET,sprintf('xsplit_c2_%03d_lock.lock',s));
		if(exist(split_lock))
			fprintf('split %03d being run\n',s);
			continue;
		end;
		save(split_lock,'split_lock');
		%---------------------------------	
		%training data
		%---------------------------------
		[trnX,trnY]= aggregate_ftr(TARGET,s,1);
		trnY       = trnY-2;
		trnX(trnY==7,:)=[]; %copy error
		trnY(trnY==7)=[];   %copy error
		%-----------------------------------
		%testing
		%-----------------------------------
		[tstX,tstY]= aggregate_ftr(TARGET,s,0);
		tstY       = tstY-2;
		tstX(tstY==7,:)=[]; %copy error
		tstY(tstY==7)=[];   %copy error
		%----------------------------------
		%train svm
		trial = 1;
		for c = [0.08 0.1 0.12] %logspace(-3,1,8);
				model = svmtrain(trnY,trnX,sprintf('-t 0 -c %f',c));
				[trn_lbl{trial},trn_acc{trial},trn_yhat{trial}]=svmpredict(trnY,trnX,model);
				[tst_lbl{trial},tst_acc{trial},tst_yhat{trial}]=svmpredict(tstY,tstX,model);
				trial = trial+1;
	   end;
	   save(split_file,'trn_lbl','tst_lbl','trn_acc','tst_acc','trn_yhat','tst_yhat','trnY','tstY');
	end;
end;
exit;
