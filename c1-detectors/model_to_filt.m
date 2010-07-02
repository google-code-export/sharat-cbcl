%--------------------------------------------------------------------------
% model_to_filt
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
function filt = model_to_filt(model,BANDS,SIZE,CALLBACK,varargin)
%------------------------------
%convert model to filter
%------------------------------
ftr  = feval(CALLBACK,rand(SIZE),varargin{:});
c1   = ftr{2}(BANDS);
hplane= model.sv_coef'*model.SVs;
keyboard;
for i = 1:length(BANDS)
  W    = hplane(1:prod(size(c1{i})));
  mX   = zeros(size(W));%model.mX;
  sX   = ones(size(W));%model.sX;
  filt{i}.f  = reshape(W,size(c1{i}));
  filt{i}.mf = reshape(mX,size(c1{i}));
  filt{i}.sf = reshape(sX,size(c1{i}));
  filt{i}.b  = -model.rho;
  hplane(1:prod(size(c1{i})))=[];
end;
