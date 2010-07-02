%--------------------------------------------------------
%get_network
% creates a neural network with the same architecture as 
% the tree. The tree has to be properly initialized
% before calling this function.You should also have the
% neural network toolbox installed for this operation.
% usage:
%      net = get_network(root)
%      root - (IN)  properly initialized fragement heirarchy
%      net  - (OUT) initialized network.
%sharat@mit.edu
%--------------------------------------------------------
function net = get_network(root)
  net    = network;
  player = 0; %parent layer
  net.numInputs        = 0;
  net.numLayers        = 0;
 
  
  net    = build_network(net,root,player);
  %set layer properties
  for i = 1:net.numLayers
    net.biasConnect(i)        = 1;
    net.layers{i}.transferFcn = 'tansig';
    net.layers{i}.size        = 1;
    net.layers{i}.initFcn     = 'initnw';
  end;
  
  %set input range
  for i = 1:net.numInputs
    net.inputs{i}.size  = 1;
    net.inputs{i}.range = [-1,1];
  end;
  
  net.OutputConnect(1) = 1;
  net.targetConnect(1) = 1;
  
  %misc parameters
  net.initFcn           = 'initlay';
  net.trainFcn          = 'trainbr';
  net.performFcn        = 'msereg';
  %net.performParam.ratio= 0.5;
  net.trainParam.epochs = 2000;
  net.trainParam.goal   = 5e-2;
  net                   = init(net);
  %make all of the weights and biases positive

  
  
  
  %input weights
  [L,I] = size(net.IW);
  for l = 1:L
    for i = 1:I
      if(~isempty(net.IW{l,i}))
    	val        = net.IW{l,i};
        net.IW{l,i}= rand(size(val));
      end;
    end;
  end;
  %network weights
  [L,L] = size(net.LW);
  for i = 1:L
    for j=1:L
       if(~isempty(net.LW{i,j}))
        val        = net.LW{i,j};
    	net.LW{i,j}= rand(size(val));
      end;  
    end;
  end;
  %biases
  for i = 1:length(net.b)
    net.b{i} = rand;%abs(net.b{i});
  end;
  
%end function

%------------------------------------------------------------
%build network
%builds the network by explroring the tree depth first
%------------------------------------------------------------
function net = build_network(net,root,player)
   if(isempty(root.h)) 
    net.numInputs    = net.numInputs +1;
    net.inputConnect(player,net.numInputs) = 1;
    return;
   end;
   net.numLayers = net.numLayers + 1;
    if(player)
     net.layerConnect(player,net.numLayers) = 1;
    end;
    player = net.numLayers;
    for i = 1:length(root.h)
         net = build_network(net,root.h(i),player);
    end;
 %end function
