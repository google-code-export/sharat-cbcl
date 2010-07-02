function plotResults
clear all;
close all;
addpath('~/utils');
SETTINGS='settings';
SZ=128;
scales=logspace(log10(0.25*SZ),log10(2*SZ),8)/6;
noise=linspace(0,0.5,8);
PLOT_ONLY=1;
if(~PLOT_ONLY)
for i=9;
    load(fullfile(SETTINGS,sprintf('set-%03d',i)),'tstY','tstTag');tstY=tstY(:);
    tstCond=[];
    nPoints=length(tstTag);
    for n=1:nPoints;
        tstCond(n)=str2num(tstTag{n}(1));
    end;
    tstCond=tstCond(:);
    accRes=[];aucRes=[];
    nIdx=1;
    for s=1:length(scales)
        for n=1:length(noise)
            fprintf('Setting:%d\n',nIdx);
             resFile=fullfile(SETTINGS,sprintf('results-%03d-%03d-%03d',i,s,n))
             load(resFile,'tstO');
             for obj=1:16
                 %no attention
                 [val,yhat]=max(squeeze(tstO(:,:,2)),[],2);%no attn
                 val=tstO(:,obj,2);val=max(0.001,val);%val=log(val./(1-val));
                 val=val(:);yhat=yhat(:);
                 accRes(obj,nIdx,1)=[mean(tstY(~tstCond & tstY==obj)==yhat(~tstCond & tstY==obj))];
                 accRes(obj,nIdx,2)=[mean(tstY(tstCond & tstY==obj)==yhat(tstCond & tstY==obj))];
                 aucRes(obj,nIdx,1)=plot_roc(val(~tstCond & tstY==obj),val(~tstCond & tstY~=obj)); 
                 aucRes(obj,nIdx,2)=plot_roc(val(tstCond & tstY==obj),val(tstCond & tstY~=obj)); 
                 %-------------------------------------------------
                 %classification with attention
                 [val,yhat]=max(squeeze(tstO(:,:,1)),[],2);%attn
                 val=tstO(:,obj,1);val=max(0.001,val);%val=log(val./(1-val));
                 yhat=yhat(:);val=val(:);
                 accRes(obj,nIdx,3)=[mean(tstY(~tstCond & tstY==obj)==yhat(~tstCond & tstY==obj))];
                 accRes(obj,nIdx,4)=[mean(tstY(tstCond & tstY==obj)==yhat(tstCond & tstY==obj))];
                 aucRes(obj,nIdx,3)=plot_roc(val(~tstCond & tstY==obj),val(~tstCond & tstY~=obj)); 
                 aucRes(obj,nIdx,4)=plot_roc(val(tstCond & tstY==obj),val(tstCond & tstY~=obj)); 
             end;%obj    
             nIdx=nIdx+1;
			 %keyboard;
        end;%n
    end;%s
end;%i    
save('plotResults','aucRes','accRes');
else
    load('plotResults','aucRes','accRes');
    %display first result
    s=2;n=1;p=(s-1)*8+n;
    figure(1);plotIdx(p,aucRes,accRes);
    %aucRes=accRes;
    %display parameter sweep
    figure(2);
    idx=1;
    for s=1:2:8
        for n=1:2:8
            p=(s-1)*8+n;
            figure(3);hold off;plotIdx(p,aucRes,accRes);title(sprintf('s=%d,n=%d',s,n));%pause;
            figure(2);subplot(4,4,idx);plotIdx(p,aucRes,accRes);set(gca,'XTickLabel',[]);axis([0.5 4-0.5 0.5 1])
            idx=idx+1;
        end;
    end;    
    figure(3); hold off;
    s=4;n=7;p=(s-1)*8+n;
    plotIdx(p,aucRes,accRes);
end;

function plotIdx(nIdx,aucRes,accRes)
    isoAuc=aucRes(:,nIdx,1);
    cltrAuc=aucRes(:,nIdx,2);
    attnAuc=aucRes(:,nIdx,4);
    %display AUC 
    bar(1,mean(isoAuc),'faceColor','blue');hold on; 
    bar(3,mean(cltrAuc),'faceColor','green');hold on; 
    bar(2,mean(attnAuc),'faceColor','red');hold on; 
    errorbar(1:3,mean([isoAuc(:),attnAuc(:),cltrAuc(:)]),...
    std([isoAuc(:),attnAuc(:),cltrAuc(:)])/sqrt(length(isoAuc)),'k.',...
        'lineWidth',2);
    axis([0.5 4-0.5 0.5 1]);set(gca,'XTickLabel',{'Isolated','Cluttered','W/ Attention'})
    %ylabel('Area under ROC','Fontsize',14) 
