%---------------------------------------------------
%MPI Stuff
%--------------------------------------------------
addpath(genpath('../MatlabMPI'));
addpath(genpath('../stprtool'));

MPI_Init;
source  = 0;
comm    = MPI_COMM_WORLD;
comm    = MatMPI_Save_messages(comm,0);
comm    = MatMPI_Comm_dir(comm,'/cbcl/scratch01/sharat/stdmodel_sharat/MatMPI');
my_rank = MPI_Comm_rank(comm);
debug   = 0;
TRAIN   = 15;

%------------------------------------
%get test data
%------------------------------------

if(my_rank == source)
  fprintf('Loading model\n');
  load svm_results_1; %contains trnX trnY model
  [D,N]   = size(trnX);
  if(debug)
    idx     = randperm(N);
    trnX    = trnX(:,idx(1:100));
    trnY    = trnY(idx(1:100));
    tstX    = tstX(:,idx(1:100));
    tstY    = tstY(idx(1:100));
  end;
else
  trnX    = [1]; trnY=[1]; model = [];
  tstX    = [1]; tstY=[1]; model = [];
end;
trn_lbl   = [];
%trn_lbl   = mpi_mvsvmclass(trnX,model,comm);
tst_lbl   = mpi_mvsvmclass(tstX,model,comm,'mvsvmclass');

if(my_rank == source)
   save svm_class_results_1 trnY trn_lbl tstY tst_lbl;
   fprintf('Training error: %f\n',mean(trnY~=trn_lbl));
   fprintf('Testing error: %f\n',mean(tstY~=tst_lbl));
   send_mail('Classification done boss. Results in svm_class_results');
end;
 
MPI_Finalize;
if (my_rank ~= MatMPI_Host_rank(comm))
 fprintf('HARAKIRI Friend\n');
 exit;
end;
