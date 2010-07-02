%-------------------------------------------------------------------------
%learn_weights
% learns the weights by iteratively optimizing position and weights
% usage 
%        [root] = learn_weights(root)
%         root  - (IN/OUT) properly initialized fragment hierarchy.
%                          this function should NOT be called
%                          before calling get_fragment_hierarchy.m
%                          and also get_optimal_roi.m
%                       
% sharat@mit.edu
%--------------------------------------------------------------------------
function root = learn_weights(root,varargin)
  ask  = 1;
  timg = [root.pos,root.neg];
  T    = [ones(1,length(root.pos)),-ones(1,length(root.neg))];
  %create a net
  if(isempty(varargin))
    net  = get_network(root);
  else
    net  = varargin{1};
  end;
  root = transfer_weights(net,root);
  loop = 1; 
  while((loop<=5 && ask == 0) || (ask))
    P    = [];
    %extract scores
    for i = 1:length(timg)
      fprintf('Processing ---->%d of %d\n',i,length(timg)); 
      [res,S] = image_response(root,timg(i).img)
      P       = [P,S'];
    end;
    %train the network
    net       = train(net,P,T);
    root      = transfer_weights(net,root);
    %safety
    save tmp_net;
    %proceed
    Y         = sim(net,P);
    err       = T-Y;
    if(ask)
      res       = input('proceed further?','s');
      if(res(1)~='y')
        break;
      end;
    elseif(mse(err)<=0.1)
      break;
    end;
    mse(err)
    loop = loop+1;
  end;
%end function learn_weights
