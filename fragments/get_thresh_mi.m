%--------------------------------------------------------------------------
%get_thresh_mi
% computes the optimal threshold for each patch based on
% maximization of mutual information. 
% usage:
%  [thresh,mi] = get_thresh_mi(pos,neg)
%       pos    - (IN)  positive score matrix (npatches X nexamples)
%       neg    - (IN)  non class score matrix
%       thresh - (OUT) thresholds for each patch (1 X npatches)
%       mi     - (OUT) corresponding mutual information (at optimal thresh)
%sharat@mit.edu
%--------------------------------------------------------------------------
function [thresh,mi] = get_thresh_mi(pos,neg)
  whos
  dbg_flag    = 0; %you can turn this on if you want
  [nptch,nftr]= size(pos);
  %for each patch
  for i = 1:nptch
    fprintf('.');
    cftr  = sort([pos(i,:),neg(i,:)]);
    maxmi = 0;
    maxth = -1;
    tmp_t = [];
    tmp_mi= [];
    %compute mi for several thresholds
    for t = linspace(cftr(1),cftr(end),250)
        hx     = entropy(cftr>=t,[0,1]);
        hx_1   = entropy(pos(i,:)>=t,[0,1]);
        hx_0   = entropy(neg(i,:)>=t,[0,1]);
        p1     = length(pos(i,:))/length(cftr);
		p0     = 1-p1;
        tmi    = hx - (p1*hx_1+p0*hx_0);
		tmp_mi = [tmp_mi,tmi];
		tmp_t  = [tmp_t,t];
        if(tmi > maxmi)
            maxth = t;
            maxmi = tmi;
        end;
    end; %end t
    if(dbg_flag)
      subplot(1,2,1); plot(pos(i,:)>maxth,'r');hold on,plot(neg(i,:)>maxth,'b');hold off;
      subplot(1,2,2); plot(tmp_t,tmp_mi);
      xlabel('Threshold'); ylabel('Mutual Information');
      pause(1);
    end;
    fprintf('Max value = (%f,%f)\n',maxth,maxmi);
    thresh(i) = maxth;
    mi(i)     = maxmi;
  end; %i
%end function get_thresh_mi
