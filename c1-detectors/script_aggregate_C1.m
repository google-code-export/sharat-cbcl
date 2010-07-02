%--------------------------------------------------------------------------
% script_aggregate_C1.m
%aggregates data into a training matrix
%NOTE: Declare global X Y before running this
%      Global variablex X Y are used to avoid having multiple
%      large matrices in memory
%
%parameters
%      TRAINING_HOME-location of the training features
%      BANDS        -which bands of C1 to use
%      MAX_FILES    -how many images per category
%      REGEX        -use 'C1'
%      SELIDX,GROUPS,LABELS-ignore for now.
%e.g.
%sharat@mit.edu
%--------------------------------------------------------------------------
function script_aggregate_C1(TRAINING_HOME,BANDS,MAXFILES,REGEX,SELIDX,GROUPS,LABELS)
close all;
warning('off','all');
addpath(genpath('~/stdmodel_sharat'));
addpath(genpath('~/utils'));
d            = dir(fullfile(TRAINING_HOME,[REGEX,'*.mat']))
if(nargin<2)
  BANDS      = 1;
end;
if(nargin<3)
  MAXFILES     =1000;
end;
if(nargin<4)
  REGEX='';
end;

if(nargin<5)
  SEL_IDX    = [];
end;

if(nargin<6)
  GROUPS     = [];
  LABELS     = [];
end;

%--------------------------------------------------------
%SIDE EFFECT!
%--------------------------------------------------------
global X Y;
%------------------------------------------------------
%determine size of the vector
tmp = load(fullfile(TRAINING_HOME,d(1).name));
ftr = getfield(tmp,'ftr');
c   = ftr{2};
tmp = c12vec(c(BANDS));
NFTR= length(tmp)
keyboard;

nftr         = length(tmp)
ndata        = length(d)
Y            = zeros(ndata,1);

for i = 1: length(d)
  fprintf('Analyzing %d of %d\n',i,length(d));
  cls_id=sscanf(d(i).name,[REGEX '_%02d_%02d.mat']);
  Y(i)  = cls_id(1);
end;
%-------------------------------
%prune max files per category
%------------------------------
if(~isempty(GROUPS))
  Y       = remap(Y,GROUPS,LABELS);
end;

LBL     = unique(Y')
idx     = [];
for lbl = LBL
  lidx   = find(Y==lbl);
  ridx   = randperm(length(lidx));
  lidx   = lidx(ridx(1:min(length(lidx),MAXFILES)));
  idx    = cat(1,idx,lidx);
  fprintf('Aggregated %d files for label %d\n',length(idx),lbl);
end;
d            = d(idx);
Y            = Y(idx);

ndata        = length(d);
fprintf('SIZE:%d X %d\n',ndata,nftr);
X            = zeros(ndata,nftr);


for i = 1:length(d)
  fprintf('Aggregating %d of %d\n',i,length(d));
  try
    tmp   = load(fullfile(TRAINING_HOME,d(i).name));
    ftr   = getfield(tmp,'ftr');
    c     = ftr{2};
    tmp   = c12vec(c(BANDS))';
    if(~isempty(SEL_IDX))
      tmp = tmp(SEL_IDX);
    end;
    X(i,:)= tmp;
    X(i,:)= X(i,:);
  catch
    %keyboard;
    continue;
end;
end;
