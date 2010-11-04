function script_compute_D(PID,PSIZE)
   addpath('/data/scratch/sharat/sc_demo');
   load training_data_8of8ClassesContour
   N         =size(X,2);
   D         =zeros(N,N,3);
   batch_size=ceil(N/PSIZE);
   start_row =(PID)*batch_size+1;
   end_row   =min(N,start_row+batch_size-1);
   dest_file =sprintf('D_%03d.mat',PID);
   for i=start_row:end_row
     ptsA=reshape(X(:,i),[100 2]);ptsA=ptsA(1:2:end,:);
     for j=1:N
       fprintf('Processing row:%d,col:%d\n',i,j);
       ptsB=reshape(X(:,j),[100 2]);ptsB=ptsB(1:2:end,:);
       [sc_cost,aff_cost,match_cost]=tps_iter(ptsA,ptsB);
       D(i,j,1)=sc_cost;
       D(i,j,2)=aff_cost;
       D(i,j,3)=match_cost;
     end;
     save(dest_file,'D','start_row','end_row','batch_size');
   end;
%end function
