function F = LeastSquareReguC(Xte, Model)
c      = Model.c;
protos = Model.protos;
sigma  = Model.sigma;
what   = Model.what;
alpha  = Model.alpha;
beta   = Model.beta;
[dim, num_protos] = size(protos);
TurnedOn = Model.TurnedOn;
switch what
    case 'gaussian'
% % % %         K    = Xte'*protos;
% % % %         K1   = ones(size(protos,2),1)*sum(Xte.^2);
% % % %         K2   = ones(size(Xte,2),1)*sum(protos.^2);
% % % %         K    = K1' - 2*K + K2;
% % % %         VTUs = [ones(size(K,1),1) exp(-K./dim/sigma^2)];
% % % %         F    = 2./(1+exp(-VTUs*c)') - 1;
%         for ii = 1:size(Xte,2)
%             D     = repmat(Xte(:,ii), [1 num_protos]);
%             diff  = D-protos;
%             VTUs  = [1 exp(-dot(diff,diff)/dim/sigma^2)];
%             F(ii) = 2./(1+exp(-dot(c,VTUs))) - 1;
%             F(ii) = dot(c,VTUs);
%         end
       
            K = ones(size(Xte,2), size(protos,2));
              for ii = 1:size(Xte,2)
                  X = repmat(Xte(:,ii),1,size(protos,2)).*TurnedOn;
                  D = (X-protos).^2;
                  D = sum(D)./sum(TurnedOn);;
                  K(ii,:) = exp(-D/sigma^2);
              end
              VTUs = [ones(size(K,1),1) K];
              F    = 2./(1+exp(-VTUs*c)') - 1;

    case 'normprod'
        % n     = .001 + sqrt(sum(Xtr.^2)'*sum(protos.^2));
        n       = .001 + sqrt(sum(Xte.^2)'*ones(1,size(protos,2)));
        res     = Xte'*protos;
        res     = res./n;
        K       = [ones(1,size(Xte,2)); 1./(1+exp(-alpha * (res - beta) ))'];
        F       = 2./(1+exp(-c'*K)) - 1;

    case 'prod'
        res     = Xte'*protos;
        K       = [ones(1,size(Xte,2)); 1./(1+exp(-alpha * (res-beta) ))'];
        F       = 2./(1+exp(-c'*K)) - 1;
end
