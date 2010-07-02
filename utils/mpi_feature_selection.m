%--------------------------------------------------------------------------
%Performs feature selection using l0 norm.
%Uses MatlabMPI to divide the task over several machines
%sharat@mit.edu
%--------------------------------------------------------------------------
function [idx,weights] = mpi_feature_selection(data,comm,svm_options,svm_func)
    if(nargin <4)
      svm_func= 'mpi_oaosvm';
    end;
    source    = 0;
    bcast_tag = 80000;
    mpi_rank  = MPI_Comm_rank(comm);
    org_data  = data;
    idx       = [];
    weights   = [];
    opt_iter   = 10;
    opt_thresh = 0.01;
    opt_dim    = 150;
      
    for i = 1:opt_iter
        %---------------------------------
        %mpi stuff
        %---------------------------------
        model = feval(svm_func,data,comm,svm_options);
	if(mpi_rank == source)
            w       = sum(abs(model.sv.X*model.Alpha),2);
	    weights = [weights,w(:)];
            data.X  = spdiag(w)*data.X;
	    nfeat   = sum(abs(w)>opt_thresh);
            fprintf('Done with iteration:%d (active features:%d)\n',i,nfeat);
	    if(nfeat < opt_dim)
	      MPI_Bcast(source,bcast_tag,comm,0);
	      break;
	    end;
	    MPI_Bcast(source,bcast_tag,comm,1);
	else
	    cont  = MPI_Recv(source,bcast_tag,comm);
            fprintf('Dest(%d) done with iteration %d\n',mpi_rank,i); 
	    if(~cont) 
	      break; 
            end;
	end;
    end;
    if(mpi_rank==source)
        idx = find(abs(w)>opt_thresh);
	MPI_Bcast(source,bcast_tag,comm,1);
    else
        MPI_Recv(source,bcast_tag,comm);
    end;
%end function

