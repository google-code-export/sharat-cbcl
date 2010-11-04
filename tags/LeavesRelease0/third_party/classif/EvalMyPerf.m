  function [P, DecValue, Model] = EvalMyPerf(Xtr, Xte, Ytr, Yte, what, varargin);
% function [P, DecValue, Model] = EvalMyPerf(Xtr, Xte, Ytr, Yte, what, varargin);


addpath('/cbcl/cbcl01/liorwolf/ohsvm/classifiers');
addpath('/cbcl/scratch02/liorwolf/osusvm');
addpath('/cbcl/cbcl01/liorwolf/aside/boosting');

% addpath('/cbcl/scratch03/serre/projects/animals');

%sPARAMSCVosusvm.thtouselooerror    = 0;
sPARAMSCVosusvm.C                  = 1;
sPARAMSCVosusvm.KERNEL             = 0; %linear kernel
%sPARAMSCVosusvm.TERMINATIONEPSILON = 1;

% sPARAMSCVosusvm.splitratio        = [60 40]; % 60 percent training
% sPARAMSCVosusvm.nrepeats          = 5; % repeat 5 times

P = find(Yte == 1);
N = find(Yte ~= 1);

switch(what)
    case 'SVM'
        Model           = CLSosusvm(Xtr, Ytr, sPARAMSCVosusvm);
        [Lab, DecValue] = CLSosusvmC(Xte, Model);
    
    case 'Boost'
        Model           = CLSgentleBoost(Xtr, Ytr);
        [Lab, DecValue] = CLSgentleBoostC(Xte, Model);
        DecValue        = DecValue';
        
    case 'NN'
        if (nargin < 6), sPARAMS.k   = 1; else sPARAMS.k = varargin{1}; end
        if (nargin < 7), sPARAMS.deg = 1; else sPARAMS.deg = varargin{2}; end
        
        Model           = CLSnn(Xtr,Ytr,sPARAMS);
        [Lab, W]        = CLSnnC(Xte,Model);

%     case 'LSR' % Least square regu
%         if (nargin < 6), sPARAMS.l = .01;                 else sPARAMS.l = varargin{1}; end
%         if (nargin < 7), sPARAMS.s = .01;                 else sPARAMS.s = varargin{2}; end
%         if (nargin < 8), sPARAMS.k = 'gaussian';          else sPARAMS.k = varargin{3}; end
%     
% %         sPARAMS.l       = sPARAMS.l/500*size(Xtr,2);
% 
%         Model           = LeastSquareRegu(Xtr, Ytr, sPARAMS);
%         DecValue        = LeastSquareReguC(Xte, Model);
%         DecValue        = DecValue';
%     
    case 'LSRRdCon' % Least square regu
        if (nargin < 6), sPARAMS.l = .01;                 else sPARAMS.l = varargin{1}; end
        if (nargin < 7), sPARAMS.s = .01;                 else sPARAMS.s = varargin{2}; end
        if (nargin < 8), sPARAMS.k = 'gaussian';          else sPARAMS.k = varargin{3}; end
    
%         sPARAMS.l       = sPARAMS.l/500*size(Xtr,2);

        Model           = LeastSquareReguWithRdNumAfferents(Xtr, Ytr, sPARAMS);
        DecValue        = LeastSquareReguWithRdNumAfferentsC(Xte, Model);
        DecValue        = DecValue';
    
    case 'LSR' % Least square regu
        if (nargin < 6), sPARAMS.l = .01;                 else sPARAMS.l = varargin{1}; end
        if (nargin < 7), sPARAMS.s = .01;                 else sPARAMS.s = varargin{2}; end
        if (nargin < 8), sPARAMS.k = 'gaussian';          else sPARAMS.k = varargin{3}; end
    
%         sPARAMS.l       = sPARAMS.l/500*size(Xtr,2);

        Model           = LeastSquareRegu(Xtr, Ytr, sPARAMS);
        DecValue        = LeastSquareReguC(Xte, Model);
        DecValue        = DecValue';
    
     case 'LSR2' % Least square regu / Lior's code
         
        if (nargin < 6), sPARAMS.LAMBDA = .01;            else sPARAMS.LAMBDA = varargin{1}; end
        if (nargin < 7), sPARAMS.KERNELPARAMS = .01;      else sPARAMS.KERNELPARAMS = varargin{2}; end
        if (nargin < 8), sPARAMS.KERNEL = 3;              else sPARAMS.KERNEL = varargin{3}; end
        
        Model    = CLSrls(Xtr,Ytr,sPARAMS);
        DecValue = CLSrlsC(Xte, Model);
%         DecValue = DecValue';
    
    case 'hedo' % Stochastic gradient
        if (nargin < 6), sPARAMS.l = .01/500*size(Xtr,2); else sPARAMS.l = varargin{1}; end
        if (nargin < 7), sPARAMS.s = .01;                 else sPARAMS.s = varargin{2}; end
        if (nargin < 8), sPARAMS.k = 'gaussian';          else sPARAMS.k = varargin{3}; end
        
        Model          = HedoSynapses(Xtr, Ytr, 'gaussian');
        DecValue       = HedoSynapsesC(Xte, Model);
        
    case 'LDA'
        Model          = fisherdiscriminant(Xtr', Ytr);
        DecValue       = fisherdiscriminantC(Xte, Model);

    case 'LDAR'
        Model          = smallfda(Xtr, Ytr);
        DecValue       = smallfdaC(Xte, Model);
end

P = get_roc_ZER2(DecValue(P),DecValue(N));
       