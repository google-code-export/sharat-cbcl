%-----------------------------------------------------------------------  
%transfer_weights
% transfers the weights from the learnt network to the fragment
% hierarchy. 
% usage:
%      root = transfer_weights(net,root)
%      net  - (IN) initialized network obtained using get_network
%      root - (IN/OUT) initialized hierarch obtained using
%                      get_fragment_hierarchy.
%
%sharat@mit.edu
%----------------------------------------------------------------------
function root = transfer_weights(net,root)
  in = 0; %input number
  ln = 0; %layer number
  [root,ln,in] = do_tw(root,net,ln,in);
%end function

%--------------------------------------------------------------------------
%do_tw (do transfer weights)
%recursive helper function for transferring weights
%
%       root - (IN/OUT) subtree of the hierarchy
%       net  - initialized network
%       ln   - (IN/OUT) number of layers processed so far
%       in   - (IN/OUT) number of inputs processed so far
%--------------------------------------------------------------------------

function [root,ln,in] = do_tw(root,net,ln,in)
  if(isempty(root.h)) %if leaf return 
     return;
  end;
  ln   = ln+1;        %non-leaf 
  this = ln;
  root.bias = net.b{this};
  for i = 1:length(root.h)
    if(isempty(root.h(i).h)) %leaf node
      in                = in+1;
      root.w(i)         = net.IW{this,in};
    else
      root.w(i)         = net.LW{this,ln+1};
      [root.h(i),ln,in] = do_tw(root.h(i),net,ln,in);
    end;
  end;
%end function
