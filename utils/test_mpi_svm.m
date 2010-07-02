%---------------------------------------------------
%MPI Stuff
%--------------------------------------------------
addpath(genpath('../MatlabMPI'));
addpath(genpath('../stprtool'));

MPI_Init;
source    = 0;
comm      = MPI_COMM_WORLD;
comm      = MatMPI_Save_messages(comm,0);
my_rank   = MPI_Comm_rank(comm);
debug     = 0;
TRAIN     = 15;
NORMALIZE = 1; 

%---------------------------------------------------
%load the data
%--------------------------------------------------
if(my_rank == source)
  %load script_data;
  load /cbcl/scratch01/bileschi/PrecomputedFeatures/Caltech256_C1pC2/Caltech256_C2;
  X    = X_C2; clear X_C2; pack;
  if(debug)
    lbl = find(y<5);
    y   = y(lbl);
    X   = X(:,lbl);
  end;
  [trnX,trnY,tstX,tstY] = split_data(X,y',TRAIN); 
  clear X; pack;
  if(NORMALIZE)
    mX   = mean(trnX,2);
    sX   = std(trnX,0,2);
    trnX = trnX-repmat(mX,1,size(trnX,2));
    tstX = tstX-repmat(mX,1,size(tstX,2));
    trnX = spdiag(1./(sX+eps))*trnX;
    tstX = spdiag(1./(sX+eps))*tstX;
  end;
  data                  = struct('X',trnX,'y',trnY);
else
  data                  = struct('X',[1],'y',[1]);
end;
%---------------------------------------------------
%
%--------------------------------------------------
%svm_opts  = struct('verb',1,'bin_svm','evalsvm','ker','linear','C',logspace(-1,1,5),'arg',[1],'num_folds',TRAIN);
svm_opts  =  struct('verb',1,'bin_svm','smo','ker','linear','C',10,'arg',[1],'tol',0.005,'eps',0.005);
model     =  mpi_oaasvm(data,comm,svm_opts);   

if(my_rank == source)
  save svm_results model trnX trnY tstX tstY;
  if(debug)
    plain_model = oaasvm(data,svm_opts);
    trn_yhat    = svmclass(trnX,model);
    trn_lbl     = svmclass(trnX,plain_model);
    fprintf('Training error: %f\n',mean(trn_yhat~=trnY));
    fprintf('Training error: %f\n',mean(trn_lbl~=trnY));
    fprintf('Agreement error: %f\n',mean(trn_lbl~=trn_yhat));
    send_mail('Done boss!\n');
  end;
end;
MPI_Finalize;
if (my_rank ~= MatMPI_Host_rank(comm))
 fprintf('HARAKIRI MY FRIEND!\n');
 exit;
end;
