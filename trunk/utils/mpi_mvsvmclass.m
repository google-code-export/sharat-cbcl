%-----------------------------------------------------
%
%
%-----------------------------------------------------
function y = mpi_mvsvmclass(X,model,comm,callback)
    %------------------------
    %mpi_stuff
    %------------------------
    source       =  0;
    mpi_size     =  MPI_Comm_size(comm);
    mpi_rank     =  MPI_Comm_rank(comm);
    bcast_tag    =  1100000; %don't use this one
    [D,N]        =  size(X);
    batch_size   =  min(500,ceil(N/(mpi_size-1+eps)))
    batch_num    =  ceil(N/batch_size)
    y            =  [];
    if(nargin<4)
      callback   = 'mvsvmclass';
    end;
    %-------------------------------
    %source despatches sub-problems
    %-------------------------------
    if(mpi_rank == source)
      for i = 1:batch_num
	idx         = (i-1)*batch_size+1:min(N,i*batch_size);
        fprintf('Creating batch size %d of %d\n',i,batch_num);
	fprintf('Range:%d to %d\n',idx(1),idx(end));
	tbl(i).dest = mod(i-1,mpi_size-1)+1;
	tbl(i).otag = MatMPI_Next_tag;
	tbl(i).idx  = idx;
      end;
      MPI_Bcast(source,bcast_tag,comm,tbl,X,model);
    end;
   
    %---------------------------------
    %workers do the classification
    %---------------------------------
    if(mpi_rank ~= source)
      [tbl,X,model] = MPI_Recv(source,bcast_tag,comm);
      for i = 1:length(tbl)
	if(mpi_rank ~= tbl(i).dest)
	  continue;
	end;
	fprintf('Dest(%d): Processing batch :%d of %d\n',mpi_rank,i,length(tbl));
	if(~isempty(tbl(i).idx))
	  fprintf('Dest(%d), Batch size: %d\n',mpi_rank,length(tbl(i).idx));
	  lbl = feval(callback,X(:,tbl(i).idx),model);
	else
	  fprintf('Empty matrix..doing nothing\n');
	  lbl = [];
	end;
	MPI_Send(source,tbl(i).otag,comm,lbl);
	fprintf('Dest(%d): Sent batch: %d of %d\n',mpi_rank,i,length(tbl));
      end;
    end;
    %-------------------------------
    %source gathers all information
    %-------------------------------
    if(mpi_rank == source)
      y     = zeros(1,N);
      for i = 1:length(tbl)
	lbl           = MPI_Recv(tbl(i).dest,tbl(i).otag,comm);
	y(tbl(i).idx) = lbl;
	fprintf('Received batch %d of %d from %d\n',i,length(tbl),tbl(i).dest);
      end;
      MPI_Bcast(source,bcast_tag,comm,1); %synch tag
     else
      MPI_Recv(source,bcast_tag,comm);
    end;
    fprintf('Dest(%d) Done with computation\n',mpi_rank);
%end function
