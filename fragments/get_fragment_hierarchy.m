%-------------------------------------------------------------------------
%get_fragment_heirarchy
% creates the hierarchy based detection. Implementation based on
% Epshtein's paper 'Feature Heirarchies for Object
% Classification'. 
% 
% usage : root = get_fragment_hierarchy(root)
%         root - (IN/OUT) encapsualtes the hierarchy. The root must
%         be initialized using intialize_root.m prior to calling
%         this function. 
%         varargin- varargin{1}- depth, varargin{2}- child
%sharat@mit.edu
%--------------------------------------------------------------------------
function root = get_fragment_hierarchy(root,varargin)
    fixed_size  =   1;
    do_hierarchy=   1;
    dbg_flag    =   0;     %you can turn this on if you want
    NMAX        =   2000;  %maximum number of patches to be used
    MAX_IMAGES  =   10;     %max images to select
    MAX_DEPTH   =   1;     %maximum depth (0 for 1 level)
    USE_MPI     =   1;
    %---------------------
    %keep track of depth
    %---------------------
    if(isempty(varargin)) 
         varargin{1} = 0; 
	 varargin{2} = 0;
    end; 

    %-------------------------------
    %check depth
    %-------------------------------
    if(varargin{1}>MAX_DEPTH)
      return;
    end;
    
    %-------------------------------
    %extract candidate patches
    %-------------------------------
    if(fixed_size)
      patches     =  get_fixed_size_patches(root.pos,NMAX,MAX_IMAGES,varargin{1});
    else
      patches     =  get_patches(root.pos,NMAX,inf);
    end;

    %-------------------------------
    %save the patches
    %-------------------------------
    eval(sprintf('save patches_%d_%d patches',varargin{1},varargin{2}));
    
    if(isempty(patches) || isempty(root.neg) || isempty(root.pos))
        return;
    end;
    
    %--------------------------------
    %get correlation scores
    %--------------------------------
    if(USE_MPI)
      nodes       = {'polestar','node-12','node-11','node-09','node-08','node-07','node-06','node-05','node-04'};
      %pos examples
      mpi_patches = root.pos;
      mpi_images  = patches;
      save('mpi_images_patches','mpi_patches','mpi_images');
      MatMPI_Delete_all;
      MatMPI_Delete_all;
      eval(MPI_Run('mpi_get_corr_score',9,nodes));
      tmp         = load('mpi_scores'); 
      pscore      = tmp.mpi_scores;
      %neg examples
      mpi_patches = root.neg;
      mpi_images  = patches;
      save('mpi_images_patches','mpi_patches','mpi_images');
      MatMPI_Delete_all;
      MatMPI_Delete_all;
      eval(MPI_Run('mpi_get_corr_score',9,nodes));
      tmp         = load('mpi_scores'); 
      nscore      = tmp.mpi_scores;
    else
      pscore      =   get_corr_score(patches,root.pos);
      nscore      =   get_corr_score(patches,root.neg);
    end;
    %-------------------------------
    %compute best patches
    %------------------------------
    [thresh,mi] =   get_thresh_mi(pscore,nscore);
    [nu,dmi]    =   get_best_patches(pscore,nscore,thresh,mi,10);
    
    if(dbg_flag) %show best patches
      eval(sprintf('save tmp_scores_%d pscore nscore',varargin{1}));%save 
      for i = 1:length(nu)
    	fprintf('nu(%d)=%d,mi(%d)=%f\n',i,nu(i),i,dmi(i));
        figure(1);imshow(patches(nu(i)).img);
    	title(sprintf('Best patch(%d)',i));
        pause(2);
      end;
    end;

    %------------------------------------------------
    %check if we need to create hierarchy
    %------------------------------------------------
    if(sum(dmi)< root.mi)
      return;
    end;
    %------------------------------------------------
    %create next level
    %------------------------------------------------
    total_mi = 0;
    for i = 1:length(nu)
         if(total_mi > root.mi && dmi(i) < 0.08)   %threshold mentioned in
            return;          %the paper
         end;  
         root.h(i).img       = patches(nu(i)).img;
         root.h(i).thresh    = thresh(nu(i));
    	 root.h(i).mi        = mi(nu(i));
         total_mi            = total_mi+dmi(i);
         %--could have used pscore,nscore below
         opt_thresh          = get_optimal_threshold(pscore(nu(i),:),root.h(i).thresh);
         root.h(i).pos       = get_frags(root.h(i).img,opt_thresh,root.pos); 
         root.h(i).neg       = get_frags(root.h(i).img,opt_thresh,root.neg);
         root.h(i).h         = [];
         %weights
    	 root.h(i).bias      = 0;
         root.w(i)           = rand;
         root.h(i).w         = [];
    	 %default roi (very strict)
         root.h(i).roi.x     = patches(nu(i)).x;
         root.h(i).roi.y     = patches(nu(i)).y;
         root.h(i).roi.h     = 1; 
         root.h(i).roi.w     = 1;
         %get hierarchy for the sub-tree
         fprintf('Hierarchy depth %d: Created child %d of %d\n',varargin{1},i,length(nu));
         nroot               = get_fragment_hierarchy(root.h(i),varargin{1}+1,i);
         root.h(i)           = nroot;
     end;
%end function

%---------------------------------------------------------
%get_optimal_threshold
% increases the positive set by 20% (see Sec 3.2)
% This is to include 'almost detected' patches. 
%---------------------------------------------------------
function thresh = get_optimal_threshold(pscore,old_thresh)
   pscore   = sort(pscore,'descend');
   def_cnt  = sum(pscore >= old_thresh); %default count
   new_cnt  = 0;
   idx      = 1;
   thresh   = old_thresh;
   while(new_cnt < 1.2*def_cnt && idx <= length(pscore))
     thresh = pscore(idx);
     idx    = idx+1;
     new_cnt= sum(pscore>= thresh);
   end;
%end function get_optimal_threshold
