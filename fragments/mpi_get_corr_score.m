%------------------------------------------------------
%mpi_get_corr_score
% computes the similarity matrix between the patches 
% and set of images. Each row corresponds to a patch
% and each column gives the response to a image
% usage:
% score = get_corr_score(patches,images)
% patches - (IN) a structure array (images are in .img)
% images  - (IN) a structure array (images are in .img)
% score   - (OUT) (npatch X nimages) size array
%         - score of 1 - very similar , 0 - not similar
%sharat@mit.edu
%-----------------------------------------------------
%---------------------------
%MPI_Stuff
%---------------------------
addpath(genpath('../../MatlabMPI'));
MPI_Init;
comm      = MPI_COMM_WORLD;
comm      = MatMPI_Save_messages(comm,0);
mpi_rank  = MPI_Comm_rank(comm);
mpi_size  = MPI_Comm_size(comm);
source    = 0;
bcast_tag  = 100000;
%------------------------
%get input
%------------------------
load mpi_images_patches; 
nptch       = length(mpi_patches);
nftr        = length(mpi_images);
mpi_scores  = zeros(nptch,nftr);

%-------------------------
%despatch work
%-------------------------
if(mpi_rank == source)
    for i = 1:nptch
      dest          = mod((i-1),mpi_size-1)+1;
      tbl(i).images = mpi_images;
      tbl(i).patch  = mpi_patches(i);
      tbl(i).itag   = MatMPI_Next_tag;
      tbl(i).otag   = MatMPI_Next_tag;
      tbl(i).dest   = dest;
    end;
    MPI_Bcast(source,bcast_tag,comm,tbl);  
    fprintf('Sent data to worker nodes\n');
end;
clear mpi_images;
clear mpi_patches;

%-------------------------
%worker nodes to the work
%-------------------------
if(mpi_rank ~= source)
  tbl = MPI_Recv(source,bcast_tag,comm);
  for i = 1:length(tbl)
       if(mpi_rank ~= tbl(i).dest)
	 continue;
       end;
       fprintf('Processing patch %d of %d\n',i,length(tbl));
       images  = tbl(i).images;
       patch      = tbl(i).patch.img;
       for j = 1:length(images)
	 img        = double(images(j).img);
	 cor        = corr_image(patch,img);
         s          = max(max(cor)); 
         score(j)   = s(1);
       end;
       %-------------------------------------
       %send result to source
       %-------------------------------------
       MPI_Send(source,tbl(i).otag,comm,score);
       fprintf('Sent output for patch %d of %d\n',i,length(tbl));
 end;
end;

%--------------------------
%collect the outputs
%--------------------------
if(mpi_rank == source)
  for i = 1:length(tbl)
    score           = MPI_Recv(tbl(i).dest,tbl(i).otag,comm);
    fprintf('Received scores %d of %d\n',i,length(tbl));
    mpi_scores(i,:) = score;
  end;
end;

%---------------------
%dump outputs
%---------------------
if(mpi_rank == source)
   save('mpi_scores','mpi_scores');
end;

%----------------------
%bye bye
%----------------------
MPI_Finalize;
if(mpi_rank ~= MatMPI_Host_rank(comm))
  fprintf('HARAKIRI my friend..BYE\n');
  exit;
end;



