%plot_curve
%plots Score distributions
%Usage plot_curve(frr_file,far_file)
%ex: plot_curve('frr_result.txt','far_result.txt');
%
function [AUC,thresh,frr,far] = plot_roc(pos,neg,varargin)
if(~isnumeric(pos))
  pos = textread(pos);
end;
if(~isnumeric(neg))
  neg = textread(neg);
end;


[far_n,far_x]=hist(neg,20);
[frr_n,frr_x]=hist(pos,20);
 far_n = far_n/length(neg);
 frr_n = frr_n/length(pos);
if(1)%isempty(varargin))
  figure(1),bar(far_x,far_n,'r');
  hold on,bar(frr_x,frr_n,'b');
  legend('impostor','genuine');
end;
%-----------------------------------
%get threshold values for fixed 
%-----------------------------------
pos     = pos+1e-4*rand(size(pos));
neg     = neg+1e-4*rand(size(neg));
scores  =   [pos(:);neg(:)];
thresh  =   sort(neg(:));%linspace(min(scores),max(scores),200);%unique();
%thresh  =   linspace(min(scores),max(scores),100);%unique();
far     =   zeros(1,length(thresh));
frr     =   zeros(1,length(thresh));

for i = 1:length(thresh)
    far(i) = sum((neg >= thresh(i)))/length(neg);
    frr(i) = 1-sum((pos < thresh(i)))/length(pos);
end;
err = min(max(far,1-frr)); 
idx = find(min(max(far,1-frr))==err);
err = err(1);

fprintf('Min error %f @ %f\n',err,thresh(idx(1)));
if(1)%isempty(varargin))
  figure(2),plot(thresh,far,thresh,1-frr,thresh,min(max(1-frr,far)),thresh,max(1-frr,far));
  legend('FAR','FRR','MIN');
end;

%----------------------------------
%eliminate duplicates
%---------------------------------
%[frr,idx] = unique(frr);
%far       = far(idx);
%----------------------------------
%interpolate at fixed values
%----------------------------------
try
    [far,idx]=sort(far);
    frr      =frr(idx);
    AUC      =trapz(far,frr)
    if(AUC<0.4)
        disp('AUC less than 0.4');
        %keyboard;
    end;    
catch
    err=lasterror;
    disp('Error occured!')
    keyboard;
end;    
if(isempty(varargin))
  figure(3),plot(far,frr,'b');xlabel('False accept rate'),ylabel('Genuine accept rate');
  title('ROC');
else
  figure(3),plot(far,frr,varargin{:});xlabel('False accept rate'),ylabel('Genuine accept rate');
  title('ROC');
end;

