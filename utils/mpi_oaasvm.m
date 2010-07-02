function model = mpi_oaasvm(data,comm,options,varargin)
% OAASVM Multi-class SVM using One-Agains-All decomposition.
% uses MatlabMPI to speedup computation.  
% Synopsis:
%  model = oaasvm( data )
%  model = oaasvm( data, options)
%
% Description:
%  model = oaasvm( data ) uses one-agains-all deconposition
%   to train the multi-class Support Vector Machines (SVM)
%   classifier. The classification into nclass classes 
%   is decomposed to nclass binary problems.
%
%  model = mpi_oaasvm( data, options) allows to specify the
%   binary SVM solver and its paramaters.
%
% Input:
%  data [struct] Training data:
%   .X [dim x num_data] Training vectors.
%   .y [1 x num_data] Labels of training data (1,2,...,nclass). 
%
%  comm [struct] MPI_WORLD_COMM parameters obtained
%                from MPI_Init
%
%  options [struct] Control parameters:
%   .bin_svm [string] Function which implements the binary SVM 
%     solver; (default 'smo').
%   .verb [1x1] If 1 then a progress info is displayed (default 0).
%  The other fileds of options specifies the options of the binary
%  solver (e.g., ker, arg, C). See help of the selected solver.
%  
% Output:
%  model [struct] Multi-class SVM classifier:
%   .Alpha [nsv x nclass] Weights (Lagrangians).
%   .b [nclass x 1] Biases of discriminant functions.
%   .sv.X [dim x nsv] Support vectors.
%   .nsv [1x1] Number of support vectors.
%   .trnerr [1x1] Training error.
%   .kercnt [1x1] Number of kernel evaluations.
%   .options [struct[ Copy of input argument options.
%
% Example:
%  data = load('pentagon');
%  options = struct('ker','rbf','arg',1,'C',10,'verb',1);
%  model = oaasvm(data,options);
%  figure; 
%  ppatterns(data); ppatterns( model.sv.X, 'ok',13);
%  pboundary( model );
%
% See also 
%  SVMCLASS, OAOSVM.
%

% About: Statistical Pattern Recognition Toolbox
% (C) 1999-2005, Written by Vojtech Franc and Vaclav Hlavac
% <a href="http://www.cvut.cz">Czech Technical University Prague</a>
% <a href="http://www.feld.cvut.cz">Faculty of Electrical Engineering</a>
% <a href="http://cmp.felk.cvut.cz">Center for Machine Perception</a>

% Modifications:
% 12-Feb-2007, sharat@mit.edu, added support for MatlabMPI
% 25-jan-2005, VF, option solver replaced by bin_svm 
% 27-may-2004, VF, completely re-programed
% 18-sep-2001, V. Franc, created

% Process inputs
%-----------------------------
if nargin < 2, options = []; else options=c2s(options); end
if ~isfield(options,'verb'), options.verb = 0; end
if ~isfield(options,'bin_svm'), options.bin_svm = 'smo'; end
if ~isfield(options,'ker'), options.ker = 'linear'; end
if ~isfield(options,'arg'), options.arg = 1; end
if ~isfield(options,'C'), options.C = inf; end

%------------------------
%mpi_stuff
%------------------------
source       =  0;
mpi_size     =  MPI_Comm_size(comm);
mpi_rank     =  MPI_Comm_rank(comm);
bcast_tag    =  999000; %don't use this tag for other purposes
model        =  [];
%-------------------------------
%source despatches sub-problems
%-------------------------------
[dim,num_data] = size(data.X);
nclass         = max(data.y);
nrule          = nclass;

if(mpi_rank == source)
  % display info
  %---------------------
  if options.verb == 1,
    fprintf('Binary rules: %d\n', nclass);
    fprintf('Training data: %d\n', num_data);
    fprintf('Dimension: %d\n', dim);
    if isfield( options, 'ker'), fprintf('Kernel: %s\n', options.ker); end
    if isfield( options, 'arg'), fprintf('arg: %f\n', options.arg(1)); end
    if isfield( options, 'C'), fprintf('C: %f\n', options.C); end
  end

  %----------------------------------------
  Alpha       = zeros(num_data,nclass);
  b           = zeros(nclass,1);
  orig_labels = data.y;
  kercnt = 0;

  % One-Against-All decomposition
  %----------------------------------------
  for i=1:nclass,
   if options.verb==1,
     fprintf('Training rule %d of %d\n', i,nrule);
   end

   % set binary subtask
   %---------------------------------------------
   bin_labels = zeros(1,num_data);
   bin_labels(find( orig_labels==i)) = 1;
   bin_labels(find( orig_labels~=i)) = 2;   
   %-----------------------------------------------
   %despatch to worker
   %-----------------------------------------------
   dest        = mod(i-1,mpi_size-1)+1;
   tbl(i).dest = dest;
   tbl(i).lbl  = bin_labels;
   tbl(i).itag = MatMPI_Next_tag;
   tbl(i).otag = MatMPI_Next_tag;
 end;
 MPI_Bcast(source,bcast_tag,comm,tbl,data,options);
end;

%-------------------------------------------------
% solve binary subtask in one of the worker nodes
%-------------------------------------------------
if(mpi_rank ~=source)
     [tbl,data,options] = MPI_Recv(source,bcast_tag,comm);
     for i = 1:length(tbl)
        dest = tbl(i).dest;
        fprintf('(Rule %d) @ (dest %d)\n',i,mpi_rank);
        if(dest ~= mpi_rank)
	  fprintf('Skipping...\n');
	  continue;
	end;
	data.y = tbl(i).lbl;
	% solve binary subtask
	%-------------------------------------
	bin_model = feval( options.bin_svm, data, options );
        %-------------------------------------------
        %send the results back
        %-------------------------------------------
        MPI_Send(source,tbl(i).otag,comm,bin_model);
	fprintf('Dest(%d)--sent SVM model(%d of %d)\n',dest,i,length(tbl));   
     end;
 end;

%-------------------------------------------------
% combine the results
%-------------------------------------------------
if(mpi_rank == source)
    for i = 1:length(tbl)
        dest                      = tbl(i).dest;
        [bin_model]               = MPI_Recv(dest,tbl(i).otag,comm);
        fprintf('received rule (%d of %d)', i, nrule );
        %-----------------------------
        % progress info 
        %----------------------------
        if options.verb ==1,
         if isfield(bin_model, 'trnerr'),
           fprintf(': trnerr = %.4f', bin_model.trnerr);
         end
         if isfield(bin_model, 'margin'),
          fprintf(', margin = %f', bin_model.margin );
         end
         fprintf('\n');
       end
       %-----------------------------
       % build model
       %-----------------------------
       Alpha(bin_model.sv.inx,i) = bin_model.Alpha(:);
       b(i) = bin_model.b;
       kercnt = kercnt + bin_model.kercnt;
     end;
end

if(mpi_rank == source)
  % set output model
  %---------------------------------
  % indices of all support vectors
  inx            = find(sum(abs(Alpha),2)~= 0);
  model.Alpha    = Alpha(inx,:);
  model.b        = b;
  model.sv.X     = data.X(:,inx);
  model.sv.y     = orig_labels(inx);
  model.sv.inx   = inx;
  model.nsv      = length(inx);
  model.kercnt   = kercnt;
  model.options  = options;
  %model.fun     = 'svmclass';
  %model.trnerr  = cerror( svmclass(data.X, model), orig_labels );
  MPI_Bcast(source,bcast_tag,comm,1); %synch tag
else
  MPI_Recv(source,bcast_tag,comm); 
end;
return;
% EOF
