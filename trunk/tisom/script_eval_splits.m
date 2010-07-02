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

IMGHOME    = fullfile(HOME,'data','OT8');
FTRHOME    = fullfile(HOME,'data','OT8Features');
SPLITS     = 1;
PARAMS     = 1:25
SCALES     = [1 0.5 0.25];

for s=SPLITS
  for p=PARAMS
  trn_file = fullfile(FTRHOME,sprintf('split_trn_%03d_%03d_data.mat',s,p));
  tst_file = fullfile(FTRHOME,sprintf('split_tst_%03d_%03d_data.mat',s,p));
  model_file = fullfile(FTRHOME,sprintf('svm_model_%03d_%03d.mat',s,p))
  lock_file  = fullfile(FTRHOME,sprintf('eval_%03d_%03d.mat',s,p));
  result_file= fullfile(FTRHOME,sprintf('split_%03d_%03d_results.mat',s,p));
  if(exist(lock_file))
    fprintf('Split:%d,%d already processed\n',s,p);
    continue;
  end;
  save(lock_file,'lock_file');
  if(~exist(trn_file))
    fprintf('%s does not exist..skipping\n',trn_file);
    continue;
  end;
  if(~exist(tst_file))
    fprintf('%s does not exist..skipping\n',tst_file);
    continue;
  end;
  
  fprintf('loading data...\n');
  load(trn_file,'X','Y');trnX=X;trnY=Y;
  load(tst_file,'X','Y');tstX=X;tstY=Y;
  clear X Y;
  trial  = 1;
  model   = {};
  tst_lbl={};tst_acc={};tst_yhat={};
  trn_lbl={};trn_acc={};trn_yhat={};
  
  for c   = logspace(-3,1,8)
    model{trial}= svmtrain(trnY,trnX,sprintf('-t 0 -c %f',c));
    [trn_lbl{trial},trn_acc{trial},trn_yhat{trial}]=svmpredict(trnY,trnX,model{trial});
    [tst_lbl{trial},tst_acc{trial},tst_yhat{trial}]=svmpredict(tstY,tstX,model{trial});
    fprintf('Split:%03d,%03d,C:%f\n',s,p,c);
    fprintf('Trianing error:%f\n',trn_acc{trial});
    fprintf('Testing error:%f\n',tst_acc{trial});
    trial = trial+1;
  end;%c
  save(result_file,'trn_lbl','trn_acc','trn_yhat',...
                   'tst_lbl','tst_acc','tst_yhat',...
		   'model');
	     
end;%p 
end;%s
exit;
