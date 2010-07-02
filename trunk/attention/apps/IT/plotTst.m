clear all;
close all;
load settings/set-009 tstY tstTag;
load tstResults;
%tstO=tstO(:,1:4,:);
%------------------------------------
%without attention
nPts=length(tstTag);
tstX=zeros(nPts,16);
tstAX=zeros(nPts,16);
for i=1:nPts
    tstCond(i)=str2num(tstTag{i}(1));
    tstX(i,:)=tstO(i,:,2);
    if(tstCond(i))
        tstAX(i,:)=tstO(i,:,1);
    end;    
end;    

res=zeros(16,3);
auc=zeros(16,3);
tstY=tstY(:);
tstCond=tstCond(:);
for obj=1:16
    [val,yhat]=max(tstX,[],2); 
    %isolated
    yhat=yhat(:);
    res(obj,1)=[mean(tstY(~tstCond & tstY==obj)==yhat(~tstCond & tstY==obj))];
    res(obj,2)=[mean(tstY(tstCond & tstY==obj)==yhat(tstCond & tstY==obj))];
    auc(obj,1)=plot_roc(val(~tstCond & tstY==obj),val(~tstCond & tstY~=obj));
    auc(obj,2)=plot_roc(val(tstCond & tstY==obj),val(tstCond & tstY~=obj));
    %-------------------------------------------------
    %classification with attention
    [val,yhat]=max(tstAX,[],2);
    yhat=yhat(:);
    res(obj,3)=[mean(tstY(tstCond & tstY==obj)==yhat(tstCond & tstY==obj))];
    auc(obj,3)=plot_roc(val(tstCond & tstY==obj),val(tstCond & tstY~=obj));
end;
keyboard;
