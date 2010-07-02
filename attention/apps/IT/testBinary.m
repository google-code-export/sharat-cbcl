function testBinary
clear all;
close all;
for s=1:36
    try
load(sprintf('settings16/set-%03d',s));
%get features and thresholds;
trnX=trnX(:,sel);
tstX=tstX(:,sel);
pO=pO(:,1:16)';
pO=max(0.5,min(pO,0.99));
trnX=trnX>=repmat(thresh(:)',size(trnX,1),1);
tstX=tstX>=repmat(thresh(:)',size(tstX,1),1);
yhat=findLL(tstX,pO);
ycap=[];
for t=1:size(tstX,1)
    [val,idx]=sort(yhat(t,:),'descend');
    ycap(t)=idx(1);
end; 
tstCond=[];
for t=1:size(tstX,1)
    tstCond(t)=str2num(tstTag{t}(1));
end;
fprintf('%d--%f,',s,mean(tstY(:)==ycap(:)));
fprintf('%f,',mean(tstY(~tstCond)==ycap(~tstCond)'));
fprintf('%f\n',mean(tstY(tstCond~=0)==ycap(tstCond~=0)'));
catch
continue;
end;
end;

function ll=findLL(X,pO)
    ll=zeros(size(X,1),size(pO,1));
    for o=1:size(pO,1)
        for t=1:size(X,1)
          ll(t,o)=sum(X(t,:).*log(pO(o,:))+(1-X(t,:)).*log(1-pO(o,:))); 
        end;    
    end;    
%end function
