function model = mpi_oaosvm(data,comm,options,varargin)
% OAOSVM Multi-class SVM using One-Against-One decomposition.
% Uses MatlabMPI to speed up computation
% Synopsis:
%  model = mpi_svm( data,comm)
%  model = mpi_svm( data,comm,options )
%
% Description:
%  model = oaosvm( data ) uses one-agains-one deconposition
%   to train the multi-class Support Vector Machines (SVM)
%   classifier. The classification into nclass classes 
%   is decomposed into nrule = (nclass-1)*nclass/2 binary 
%   problems. MatlabMPI is used to speed up the computation
%
%  model = mpi_svm( data, comm,options) allows to specify the
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
%  The other fields of options specifies the options of the binary
%  solver (e.g., ker, arg, C). See help of the selected solver.
%
% Output:
%  model [struct] Multi-class SVM majority voting classifier:
%   .Alpha [nsv x nrule] Weights (Lagrangeans).
%   .bin_y [2 x nrule] Translation between binary responses of
%     the discriminant functions and class labels.
%   .b [nrule x 1] Biases of discriminant functions.
%   .sv.X [dim x nsv] Support vectors.
%   .nsv [1x1] Number of support vectors.
%   .trnerr [1x1] Training error.
%   .kercnt [1x1] Number of kernel evaluations.
%   .options [struct[ Copy of input argument options.
%
%  Uses broadcast tag 900000 
% Example:
%  MPI_Init;
%  comm = MPI_WORLD_COMM
%  data = load('pentagon');
%  options = struct('ker','rbf','arg',1,'C',1000,'verb',1);
%  model = mpi_svm( data, comm,options );
%  figure; 
%  ppatterns(data); ppatterns(model.sv.X,'ok',13);
%  pboundary( model );
%  
% See also 
%  MVSVMCLASS, OAASVM.
%

% About: Statistical Pattern Recognition Toolbox
% (C) 1999-2005, Written by Vojtech Franc and Vaclav Hlavac
% <a href="http://www.cvut.cz">Czech Technical University Prague</a>
% <a href="http://www.feld.cvut.cz">Faculty of Electrical Engineering</a>
% <a href="http://cmp.felk.cvut.cz">Center for Machine Perception</a>

% Modifications:
% 31-Dec-2006, sharat@mit.edu, added support for MatlabMPI
% 25-jan-2005, VF, option solver replaced by bin_svm 
% 26-may-2004, VF
% 4-feb-2004, VF
% 9-Feb-2003, VF
% Process inputs
%-----------------------------
if nargin < 3, options = [];  end
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
bcast_tag    =  900000;
model        =  [];
%-------------------------------
%source despatches sub-problems
%-------------------------------
[dim,num_data] = size(data.X);
nclass         = max(data.y);
nrule          = (nclass-1)*nclass/2;

if(mpi_rank == source)

  % display info
    %---------------------
    if options.verb == 1,
      fprintf('Binary rules: %d\n', nrule);
      fprintf('Training data: %d\n', num_data);
      fprintf('Dimension: %d \n', dim);
      if isfield( options, 'ker'), fprintf('Kernel: %s\n', options.ker); end
      if isfield( options, 'arg'), fprintf('arg: %f\n', options.arg(1)); end
      if isfield( options, 'C'), fprintf('C: %f\n', options.C); end
    end

    %----------------------------------------
    Alpha = zeros(num_data,nrule);
    b     = zeros(nrule,1);
    bin_y = zeros(2,nrule);
    kercnt = 0;

    % One-Against-One decomposition
    %-----------------------------------
    rule = 0;
    for class1 = 1:nclass-1,
      for class2 = class1+1:nclass,
        rule = rule + 1;
        % set binary subtask
        %---------------------------------------------
        bin_y(1,rule) = class1;
        bin_y(2,rule) = class2;
        %-----------------------------------------------
        %despatch to worker
        %-----------------------------------------------
	dest              = mod(rule-1,mpi_size-1)+1;
	tbl(rule).dest    = dest;
        tbl(rule).class   = [class1,class2];
        tbl(rule).itag    = MatMPI_Next_tag;
        tbl(rule).otag    = MatMPI_Next_tag;
      end;
    end;
    MPI_Bcast(source,bcast_tag,comm,tbl,data,options);
end;%end despatch

%-------------------------------------------------
% solve binary subtask in one of the worker nodes
%-------------------------------------------------
if(mpi_rank ~=source)
     [tbl,data,options] = MPI_Recv(source,bcast_tag,comm);
     for i = 1:length(tbl)
        dest     = tbl(i).dest;
        fprintf('(Rule %d) @ (dest %d)\n',i,mpi_rank);
        if(dest ~= mpi_rank)
	  fprintf('Skipping...\n');
	  continue;
	end;
	data_inx   = find(data.y == tbl(i).class(1) | data.y == tbl(i).class(2));
        bin_data.X = data.X(:, data_inx);
        bin_data.y = data.y(data_inx);
        bin_data.y(find(bin_data.y == tbl(i).class(1))) = 1;
        bin_data.y(find(bin_data.y == tbl(i).class(2))) = 2;
        bin_model = feval(options.bin_svm,bin_data,options);
        %-------------------------------------------
        %send the results back
        %-------------------------------------------
        MPI_Send(source,tbl(i).otag,comm,bin_model,tbl(i).class);
	fprintf('Dest(%d)--sent SVM model(%d of %d)\n',dest,i,length(tbl));   
     end;
end;

%-------------------------------------------------
% combine the results
%-------------------------------------------------
if(mpi_rank == source)
    for i = 1:length(tbl)
        dest                      = tbl(i).dest;
        [bin_model,class]         = MPI_Recv(dest,tbl(i).otag,comm);
        fprintf('received rule (%d of %d)', i, nrule );
        %-----------------------------
        % progress info
        %-----------------------------
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
	data_inx                            = find(data.y == tbl(i).class(1) | data.y == tbl(i).class(2));
        Alpha(data_inx(bin_model.sv.inx),i) = bin_model.Alpha(:);
        b(i)                                = bin_model.b;
        kercnt                              = kercnt + bin_model.kercnt;
    end
end;
		      
if(mpi_rank == source)
    % set output model
    %---------------------------------
    % indices of all support vectors
    inx = find(sum(abs(Alpha),2)~= 0);
    model.Alpha = Alpha(inx,:);
    model.b = b;
    model.bin_y = bin_y;
    model.sv.X = data.X(:,inx);
    model.sv.y = data.y(inx);
    model.sv.inx = inx;
    model.nsv = length(inx);
    model.kercnt = kercnt;
    model.options = options;
    %model.fun    = mvsvmclass;
    %model.trnerr = cerror( mvsvmclass(data.X, model), data.y )
    % display info
    %--------------------
    MPI_Bcast(source,bcast_tag,comm,1);
    return;
else
    MPI_Recv(source,bcast_tag,comm); %synchronize exit
end;
% EOF



