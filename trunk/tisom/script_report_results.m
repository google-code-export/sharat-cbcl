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

FTRHOME    = fullfile(HOME,'data','OT8Features');
SPLITS     = 1;
PARAMS     = 1:25

for s=SPLITS
  for p=PARAMS
  result_file= fullfile(FTRHOME,sprintf('split_%03d_%03d_results.mat',s,p));
  if(~exist(result_file))
    fprintf('%s does not exist..skipping\n',result_file);
    continue;
  end;
  fprintf('loading data...\n');
  trn_file = fullfile(FTRHOME,sprintf('split_trn_%03d_%03d_data.mat',s,p));
  tst_file = fullfile(FTRHOME,sprintf('split_tst_%03d_%03d_data.mat',s,p));
  %load(trn_file,'Y');trnY=Y;
  %load(tst_file,'Y');tstY=Y;
  load(result_file,'trn_acc','tst_acc');
  fprintf('Split:%03d,Param:%03d\n',s,p);      
  fprintf('Training accuracy:\n');
  for i=1:length(trn_acc)
    fprintf('Trial:%d,Training:%.2f,Testing:%.2f\n',i,trn_acc{i}(1),tst_acc{i}(1));
  end;
  fprintf('---------------------------------\n');
end;%p 
end;%s

