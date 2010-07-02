%------------------------------------------------------------------------------
%
%
%sharat@mit.edu
%uses broadcast tag 70000
%-----------------------------------------------------------------------------
addpath(genpath('/cbcl/scratch03/sharat/stprtool'));
addpath(genpath('/cbcl/scratch03/sharat/stdmodel_sharat'));
addpath(genpath('/cbcl/scratch03/sharat/MatlabMPI'));
addpath('/cbcl/scratch01/sharat/MatlabSIFT');
warning('off','all');
HOME            = '/cbcl/scratch03/sharat/latest_irvine_images';
TRAINING        = 15;
TESTING         = 500;
EXT             = 'pgm';
CALLBACK        = 'callback_c2_baseline';
PATCH_CALLBACK  = 'get_dictionary_patches';
FEATURE_SELECTION  =1;
PATCHES_PER_IMAGE  =20;
INCLUDE_BG_TRAIN   =1;
SKIP_BACKGROUND    =0;
C                  =1; %svm cost function
NORMALIZE_FEATURES =0;
SVM_FUNC           ='mpi_oaasvm';
SVM_CLASS_FUNC     ='svmclass';
%---------------------------
%MPI_Stuff
%---------------------------
MPI_Init;
comm      = MPI_COMM_WORLD; 
comm      = MatMPI_Save_messages(comm,0);
comm      = MatMPI_Comm_dir(comm,'/cbcl/scratch01/sharat/mpi');
mpi_rank  = MPI_Comm_rank(comm);
mpi_size  = MPI_Comm_size(comm)
source    = 0;

bcast_tag   = 999999;
%---------------------------
%scan through the classes
%---------------------------
dir_class    = dir(HOME);
dir_class    = dir_class(3:end);
cls_lbl      = 1:length(dir_class);

trn_idx      = 1;
tst_idx      = 1;

if(mpi_rank == source)
  fprintf('Scanning directory for training and testing images\n');
  %---------------------------------
  %fetch training and testing files
  %----------------------------------
  for i = 1:length(dir_class)
    fprintf('Processing directory: %s(%d of %d)\n',dir_class(i).name,i,length(dir_class));
    files = dir(fullfile(HOME,dir_class(i).name,sprintf('*.%s',EXT)));
    fprintf('Total files:%d\n',length(files));
    idx   = randperm(length(files));
    for j = 1:min(TRAINING,length(files))
      trn(trn_idx).name = fullfile(HOME,dir_class(i).name,files(idx(j)).name);
      trn(trn_idx).class= cls_lbl(i);
      trn_idx           = trn_idx+1;
    end;
    for j = TRAINING+1:min(length(files),TRAINING+TESTING)
      tst(tst_idx).name = fullfile(HOME,dir_class(i).name,files(idx(j)).name);
      tst(tst_idx).class= cls_lbl(i);
      tst_idx           = tst_idx+1;
    end;
  end;
end;

%-----------------------------------
%build dictionary across nodes
%-----------------------------------
if(mpi_rank == source)
  fprintf('Building dictionary\n');
  if(SKIP_BACKGROUND)
    patch_trn = trn([trn.class]~=cls_lbl(end)); %skip background
  else
    patch_trn = trn;
  end;
  for i = 1:length(patch_trn)
    dest            = mod(i-1,mpi_size-1)+1;
    fprintf('Processing file :%s->dest(%d)\n',patch_trn(i).name,dest);
    img             = im2double(imread(patch_trn(i).name));
    tbl(i).dest     = dest;
    tbl(i).img      = img;
    tbl(i).itag     = MatMPI_Next_tag;
    tbl(i).otag     = MatMPI_Next_tag;
  end;
  MPI_Bcast(source,bcast_tag,comm,tbl);
end;

%--------------------------------------
%worker nodes do all the work
%---------------------------------------
if(mpi_rank ~=source)
  tbl   = MPI_Recv(source,bcast_tag,comm);
  for i = 1:length(tbl)
    dest         = tbl(i).dest;
    if(dest ~=mpi_rank) continue; end;
    img{1}         = tbl(i).img;
    patches        = feval(PATCH_CALLBACK,img,struct('bands',[2:4],'num_patches',PATCHES_PER_IMAGE));
    fprintf('Sending patches for image %d of %d\n',i,length(tbl));
    MPI_Send(source,tbl(i).otag,comm,patches);
  end;
end;

%------------------------------------------
%gather the patches together
%------------------------------------------
patches = [];
if(mpi_rank == source)
  for i = 1:length(tbl)
    dest        = tbl(i).dest;
    tmp_patches = MPI_Recv(dest,tbl(i).otag,comm);
    patches     = [patches,tmp_patches];
    fprintf('Received %d patches from (status: %d of %d)\n',length(tmp_patches),i,length(tbl));
  end;
  save script_patches patches;
  send_mail('Done with building dictionary');
  fprintf('Despatching images to workers\n');
  %-------------------------------------------------
  %despatch feature extraction task to worker nodes
  %-------------------------------------------------
  clear tbl;
  for i = 1:length(trn)
    dest        = mod(i-1,mpi_size-1)+1;
    tbl(i).dest = dest;
    tbl(i).img  = im2double(imread(trn(i).name));
    tbl(i).class= trn(i).class;
    tbl(i).itag = MatMPI_Next_tag;
    tbl(i).otag = MatMPI_Next_tag;
  end;
  MPI_Bcast(source,bcast_tag,comm,patches,tbl);
  send_mail('Done with despatching training images');
end;

%-----------------------------
%the worker nodes compute C2
%-----------------------------
if(mpi_rank~=source)
  [patches,tbl] = MPI_Recv(source,bcast_tag,comm);
  for i = 1:length(tbl)
    dest     = tbl(i).dest;
    if(mpi_rank ~= dest) 
      continue;
    end;
    img      = tbl(i).img;
    ftr      = feval(CALLBACK,img,patches);
    MPI_Send(source,tbl(i).otag,comm,ftr{1}(:),tbl(i).class);
    fprintf('Dest(%d)-sent training features %d of %d\n',dest,i,length(tbl));
  end;
end;

%--------------------------------
%gather the outputs
%--------------------------------
trnX  = [];
trny  = [];

if(mpi_rank == source)
  for i = 1:length(tbl)
    dest       = tbl(i).dest;
    [c2,class] = MPI_Recv(dest,tbl(i).otag,comm);
    fprintf('Received features class -%d, (%d of %d)\n',class,i,length(tbl));
    trnX       = [trnX,c2(:)];
    trny       = [trny,class];
  end;
  %----------------------------------
  %perform Z transform
  %----------------------------------
  mX           = mean(trnX,2);
  sX           = std(trnX,0,2);
  if(NORMALIZE_FEATURES)
    trnX         = (trnX-repmat(mX,1,size(trnX,2)));
    trnX         = spdiag(1./(sX+eps))*trnX;
  end;
  %----------------------------------
  %save
  %----------------------------------
  save script_training_data trnX trny mX sX;
  send_mail('Received all input features');
else
  trnX = [1]; trny=[1];
end;


%--------------------------------
%perform feature selection
%--------------------------------
fprintf('Performing feature selection\n');
options       = struct('iter',20,'thresh',0.005);
svm_options   = struct('bin_svm','smo','verb',1,'ker','linear','C',C);
if(FEATURE_SELECTION)
  [idx,W] = mpi_feature_selection(struct('X',trnX,'y',trny),comm,svm_options,SVM_FUNC);
else
  idx = 1:size(trnX,1);
  W   = [];
end;
%---------------------------------------
%get the best model
%---------------------------------------
if(mpi_rank == source)
  trnX       = trnX(idx,:);
  mX         = mX(idx);
  sX         = sX(idx);
  fprintf('Number of features selected:%d\n',idx);
  if(~INCLUDE_BG_TRAIN)
     bgidx    = find(trny~=cls_lbl(end));
     trnX     = trnX(:,bgidx);
     trny     = trny(bgidx);
  end;
end;

%##TODO
%perform cross validation
%
svm_options  = struct('verb',1,'ker','linear','bin_svm','smo','C',C,'arg',[1]);
model        = feval(SVM_FUNC,struct('X',trnX,'y',trny),comm,svm_options);
[yhat]       = mpi_svm_classify(trnX,model,comm,SVM_CLASS_FUNC);

if(mpi_rank == source)
  msg      = sprintf('Training error:%f\n',mean(yhat~=trny));
  model.mX = mX;
  model.sX = sX;
  save script_training_data trnX trny yhat idx msg model W;
  fprintf('%s\n',msg);
  send_mail(msg);
end;

%---------------------------------------
%get features
%from testing data.
%Despatch testing data
%--------------------------------------
if(mpi_rank==source)
  clear tbl;
  for i = 1:length(tst)
   dest          = mod(i-1,mpi_size-1)+1;
   tbl(i).dest   = dest;
   tbl(i).itag   = MatMPI_Next_tag;
   tbl(i).otag   = MatMPI_Next_tag;
   tbl(i).img    = im2double(imread(tst(i).name));
   tbl(i).class  = tst(i).class;
   fprintf('.');
  end;
  MPI_Bcast(source,bcast_tag,comm,patches,tbl)
end;

%---------------------------------------
%the worker nodes extract features
%--------------------------------------
if(mpi_rank~=source)
  [patches,tbl] = MPI_Recv(source,bcast_tag,comm);
  for i = 1:length(tbl)
    dest        = tbl(i).dest;
    if(mpi_rank~=dest)
      continue;
    end;
    img  = tbl(i).img;
    ftr  = feval(CALLBACK,img,patches);
    fprintf('Dest(%d)-Sending test output :%d of %d\n',dest,i,length(tbl));
    MPI_Send(source,tbl(i).otag,comm,ftr{1}(:),tbl(i).class);
  end;
end;


%---------------------------------------
%get the features
%--------------------------------------
if(mpi_rank == source)
  tstX = []; tsty = [];
  for i = 1:length(tbl)
    dest       = tbl(i).dest;
    [c2,class] = MPI_Recv(dest,tbl(i).otag,comm);
    fprintf('Received testing input,(%d of %d)\n',i,length(tbl));
    tstX          = [tstX,c2(:)];
    tsty          = [tsty,class];
  end;
  if(FEATURE_SELECTION)
    tstX       = tstX(idx,:);
  end;
  %--------------------------------------------
  %normalize output
  %-------------------------------------------
  if(NORMALIZE_FEATURES)
    tstX         = (tstX-repmat(mX,1,size(tstX,2)));
    tstX         = spdiag(1./(sX+eps))*tstX;
  end;
  send_mail('Received all testing features');
else
  tstX =[1]; tstY=[1];
end;


%-----------------------------------------
%get the testing results
%-----------------------------------------
[yhat,yval] = mpi_svm_classify(tstX,model,comm,SVM_CLASS_FUNC);

if(mpi_rank==source)
  msg = sprintf('Testing error  = %f\n',mean(yhat~=tsty));
  save script_testing_data tstX tsty yhat yval;
  fprintf('%s\n',msg);
  send_mail(msg);
end;

MPI_Finalize;
if(mpi_rank ~= MatMPI_Host_rank(comm))
  fprintf('HARAKIRI my friend..BYE\n');
  exit;
end;

