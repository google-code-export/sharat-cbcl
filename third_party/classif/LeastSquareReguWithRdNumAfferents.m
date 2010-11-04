  function Model = LeastSquareReguWithRdNumAfferents(Xtr, Ytr, sPARAMS);
% function Model = LeastSquareReguWithRdNumAfferents(Xtr, Ytr, sPARAMS);

lambda = sPARAMS.l;
sigma  = sPARAMS.s;
what   = sPARAMS.k;
dim    = size(Xtr,1);
nTrain = length(Ytr);

N      = 4;
nIter  = 1;


%% select 2/N prototypes

nPvtus = ceil( sum(Ytr >0) / N);
nNvtus = ceil( sum(Ytr~=1) / N);
% nNvtus = 0;
nvtus  = nPvtus+nNvtus;

% % nCon   = ceil(rand(nvtus,1)*dim);

nCon   = ceil(ones(nvtus,1)*dim);

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
    

    %% Select connections to turn off

    TurnedOn = zeros(size(protos));
    for ii = 1:size(protos,2) 
        I = randperm(size(protos,1));
        I = find(I <= nCon(ii));
        TurnedOn(I,ii) = 1;
    end
    
%     R           = rand(size(protos));
%     tmp         = sort(R);
%     TurnedOn    = R <= (ones(dim,1)*tmp(ceil(nCon),:));
%     protos      = protos.*TurnedOn - protos.*(1-TurnedOn);
%     I           = find(sum(protos>0)<nCon);
%     protos(:,I) = [];

    protos = protos.*TurnedOn;
    
    %% make K matrix
    switch what
        case 'gaussian'
%             K  = Xtr'*(protos.*TurnedOn);
%             K1 = ones(size(protos,2),1)*sum(Xtr.^2);
%             K2 = ones(size(Xtr,2),1)   *sum(protos.^2);
%             K  = K1' - 2*K + K2;
%             K  = exp(-K./dim/sigma^2);
%             K  = [ones(1,nTrain); K'];

              K = ones(size(Xtr,2), size(protos,2));
              for ii = 1:size(Xtr,2)
                  X = repmat(Xtr(:,ii),1,size(protos,2)).*TurnedOn;
                  D = (X-protos).^2;
                  D = sum(D)./sum(TurnedOn);
                  K(ii,:) = exp(-D/sigma^2);
              end

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
    
    model.TurnedOn = TurnedOn;
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
        Res      = get_roc_ZER(DecValue(find(Ytr>0))',DecValue(find(Ytr<0))');
        perf     = Res.errSame;
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
