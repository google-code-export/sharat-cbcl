%------------------------------------------------------------------------------
%
%
%sharat@mit.edu
%uses broadcast tag 70000
%outputs script_data script_svm
%-----------------------------------------------------------------------------
addpath(genpath('/cbcl/scratch03/sharat/stprtool'));
addpath(genpath('/cbcl/scratch03/sharat/stdmodel_sharat'));
addpath(genpath('/cbcl/scratch03/sharat/MatlabMPI'));
addpath('/cbcl/scratch01/sharat/MatlabSIFT');
warning('off','all');
HOME            = '/cbcl/scratch03/sharat/manu';
EXT             = 'jpg';
CALLBACK        = 'callback_c2_baseline';
PATCH_CALLBACK  = 'get_dictionary_patches';
FEATURE_SELECTION  = 0; 
PATCHES_PER_IMAGE  = 20;
SKIP_BACKGROUND    = 0;
%---------------------------
%MPI_Stuff
%---------------------------
MPI_Init;
comm      = MPI_COMM_WORLD;
comm      = MatMPI_Save_messages(comm,0);
comm      = MatMPI_Comm_dir(comm,'/cbcl/scratch01/sharat/mpi');
mpi_rank  = MPI_Comm_rank(comm);
mpi_size  = MPI_Comm_size(comm);
source    = 0;

bcast_tag   = 1999999;
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
  %fetch files
  %----------------------------------
  for i = 1:length(dir_class)
    fprintf('Processing directory: %s(%d of %d)\n',dir_class(i).name,i,length(dir_class));
    files = dir(fullfile(HOME,dir_class(i).name,sprintf('*.%s',EXT)));
    fprintf('Total files:%d\n',length(files));
    for j = 1:length(files)
      trn(trn_idx).name = fullfile(HOME,dir_class(i).name,files(j).name);
      trn(trn_idx).class= i;
      trn_idx           = trn_idx+1;
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
    fprintf('Processing file :%s\n',patch_trn(i).name);
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
    patches        = feval(PATCH_CALLBACK,img,struct('bands',[2:5],'num_patches',PATCHES_PER_IMAGE));
    fprintf('Sending patches for image %d of %d\n',i,length(tbl));
    MPI_Send(source,tbl(i).otag,comm,patches);
  end;
end;

%------------------------------------------
%gather the patches together
%------------------------------------------
patches = patches_c2m;
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
X     = [];
y     = [];

if(mpi_rank == source)
  for i = 1:length(tbl)
    dest       = tbl(i).dest;
    [c2,class] = MPI_Recv(dest,tbl(i).otag,comm);
    fprintf('Received features class -%d, (%d of %d)\n',class,i,length(tbl));
    X          = [X,c2(:)];
    y          = [y,class];
  end;
  save script_data X y;
  send_mail('Training done');
end;

MPI_Finalize;

if(mpi_rank ~= MatMPI_Host_rank(comm))
  fprintf('HARAKIRI my friend..BYE\n');
  exit;
end;

