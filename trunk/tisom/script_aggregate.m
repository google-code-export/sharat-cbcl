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
IMGHOME    = fullfile(HOME,'data','OT8');
FTRHOME    = fullfile(HOME,'data','OT8Features');
PARAMS     = 1:25
SPLITS     = 1;
SCALES     = [1 0.5 0.25];
for s = SPLITS
for p=PARAMS
  split_file = fullfile(FTRHOME,sprintf('split_%03d',s));
  for t={'tst','trn'}
    load(split_file,'img_set','trn_set','tst_set','Y');
    t         = char(t);
    dest_file = fullfile(FTRHOME,sprintf('split_%s_%03d_%03d_data.mat',t,s,p));
    lock_file = fullfile(FTRHOME,sprintf('aggregate_%s_%03d_%03d.lock',t,s,p));
    if(exist(lock_file))
      fprintf('Aggregate:%03d,%03d already exists\n',s,p);
      continue;
    end;
    save(lock_file,'lock_file');
    if(strcmp(t,'trn'))
      idx    =trn_set{1};
      img_set=img_set(idx);
      Y      =Y(idx);
    else
      idx    =tst_set{1};
      img_set=img_set(idx);
      Y      =Y(idx);
    end;
    ftr_file = fullfile(FTRHOME,sprintf('%s_%03d_%03d_%03d.mat',t,s,p,1));
    if(~exist(ftr_file))
      fprintf('%s\n does not exist yet!Skipping..\n');
      continue;
    end;
    load(ftr_file,'ftr');
    dim  =length(ftr(:));
    X    =zeros(length(img_set),dim);
    for f=1:length(img_set)
      fprintf('reading(%s,%d,%d):%d of %d\n',t,s,p,f,length(img_set));
      ftr_file = fullfile(FTRHOME,sprintf('%s_%03d_%03d_%03d.mat',t,s,p,f));
      if(~exist(ftr_file))
	fprintf('Not found %s\n',ftr_file);
	continue;
      end;
      try
	load(ftr_file,'ftr');
	X(f,:)   = ftr(:)';
      catch
	fprintf('Not loaded %s\n',ftr_file);
	continue;
      end;
    end;
    save(dest_file,'X','Y');
  end;%t
end;%p  
end;%s
exit;
