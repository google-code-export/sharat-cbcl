function Model = LeastSquareRegu(Xtr, Ytr, sPARAMS);
% function Model = LeastSquareRegu(Xtr, Ytr, sPARAMS);

lambda = sPARAMS.l;
sigma  = sPARAMS.s;
what   = sPARAMS.k;
dim    = size(Xtr,1);
nTrain = length(Ytr);

N      = 2;
nIter  = 1;

%% select 2/N prototypes

nPvtus = ceil( sum(Ytr >0) / N)
nNvtus = ceil( sum(Ytr~=1) / N)
% nNvtus = 0;
nvtus  = nPvtus+nNvtus;
Mperf  = 0;

a  = 1/std(Xtr(:));
b  = mean(Xtr(:));

% a=1;
% b=.1;
for ii = 1:nIter

    %% select centers for VTUs
    pos    = find(Ytr > 0);
    I      = randperm(length(pos));
    protos = Xtr(:,pos(I(1:nPvtus)));
 
    neg    = find(Ytr ~= 1);
    I      = randperm(length(neg));
    protos = [protos Xtr(:,neg(I(1:nNvtus)))];
    
    
    %% make K matrix
    switch what
        case 'gaussian'
            K  = Xtr'*protos;
            K1 = ones(size(protos,2),1)*sum(Xtr.^2);
            K2 = ones(size(Xtr,2),1)   *sum(protos.^2);
            K  = K1' - 2*K + K2;
            K  = exp(-K./dim/sigma^2);
            K  = [ones(1,nTrain); K'];

        case 'normprod'
            

            K(1,:)         = ones(1,nTrain);
%           n              = .001 + sqrt(sum(Xtr.^2)'*sum(protos.^2));
            n              = .001 + sqrt(sum(Xtr.^2)'*ones(1,size(protos,2)));
            res            = Xtr'*protos;
            res            = res./n;
            a              = 1/std(res(:));
            b              = mean(res(:));
            K(2:1+nvtus,:) = 1./(1+exp(-a * (res - b) ))';
%             K(2:1+nvtus,:) = (res./n)';

        case 'prod'
%             alpha  = 1;
%             beta   = .1;
     
            K(1,:)         = ones(1,nTrain);
            res            = Xtr'*protos;
            a              = 1/std(res(:));
            b              = mean(res(:));
            K(2:1+nvtus,:) = 1./(1+exp(-a * (res - b) ))';
%             K(2:1+nvtus,:) = res';

    end


    c = (K+lambda*nTrain*eye(nvtus+1,nTrain))'\Ytr;
    Kprime       = K+lambda*nTrain*eye(nvtus+1,nTrain);
    %keyboard;
    model.c      = c;
    model.protos = protos;
    model.sigma  = sigma;
    model.lambda = lambda;
    model.what   = what;
    model.alpha  = a;
    model.beta   = b;
    model.y      = [ones(1,nPvtus) -ones(1,nNvtus)];
    Model        = model;

    %% evaluate error on training set
    if nIter > 1
        DecValue = LeastSquareReguC(Xtr, model);
        %Res      = get_roc_ZER(DecValue(find(Ytr>0))',DecValue(find(Ytr<0))');
        %perf     = Res.errSame;
		perf      = mean(sign(DecValue(:))==Ytr(:));
        fprintf(1,'%2.2f ', perf*100);
        if (perf > Mperf)
            Mperf        = perf;
            Model.c      = c;
            Model.protos = protos;
            Model.sigma  = sigma;
            Model.lambda = lambda;
            Model.what   = what;
            Model.y      = [ones(1,nPvtus) -ones(1,nNvtus)];
        end
    end
end
fprintf(1,'RBF training done \n');
