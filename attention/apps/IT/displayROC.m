%----------------------------------------------------------
%
%
clear all;
close all;
tidx    =1;
nTasks  =3;
NEYE    =3;
THRESH  =0.001:0.05:1;
for type={'90','mi','adaboost'}
    resFile=sprintf('results-%s',char(type));
    swpFile=sprintf('results-switch-%s',char(type));
    humFile=sprintf('results-human');
    hsFile =sprintf('results-switch-human');
    res=load(resFile,'det','tot','area');
    hum=load(humFile,'det','tot','area');
    swp=load(swpFile,'det','tot','area');
    hs=load(hsFile,'det','tot','area');
    figure(tidx);
    for n=1:NEYE
        for t=1:nTasks
            subplot(NEYE,nTasks,(n-1)*nTasks+t);
            errorbar(THRESH,mean(res.det{n,t}./res.tot{n,t}),std(res.det{n,t}./res.tot{n,t}),'r');hold on;
            errorbar(THRESH,mean(hum.det{n,t}./hum.tot{n,t}),std(hum.det{n,t}./hum.tot{n,t}),'g')
            errorbar(THRESH,mean(swp.det{n,t}./swp.tot{n,t}),std(swp.det{n,t}./swp.tot{n,t}),'b');
            %errorbar(mean(hs.det{n,t}./hs.tot{n,t}),std(hs.det{n,t}./hs.tot{n,t}),'k');
            axis([0 1 0 1]);
            %legend('Model','Human','M-Control','H-Control')
            legend('Model','Human','M-Control')
            title(sprintf('Overlap:%.3f',mean(res.area{n,t})/mean(hum.area{n,t})));
        end;
    end; 
    set(gcf,'Name',char(type))
    tidx=tidx+1;
end;

for type={'90','mi','adaboost'}
    resFile=sprintf('results-pos-%s',char(type));
    humFile=sprintf('results-pos-human');
    res=load(resFile,'det','tot','area');
    hum=load(humFile,'det','tot','area');
    hs=load(hsFile,'det','tot','area');
    figure(tidx);
    for n=1:NEYE
        for t=1:nTasks
            subplot(NEYE,nTasks,(n-1)*nTasks+t);
            errorbar(THRESH,mean(res.det{n,t}./res.tot{n,t}),std(res.det{n,t}./res.tot{n,t}),'r');hold on;
            errorbar(THRESH,mean(hum.det{n,t}./hum.tot{n,t}),std(hum.det{n,t}./hum.tot{n,t}),'g')
            axis([0 1 0 1]);
            legend('Model','Human')
            title(sprintf('Overlap:%.3f',mean(res.area{n,t})/mean(hum.area{n,t})));
        end;
    end; 
    set(gcf,'Name',[char(type) '-pos'])
    tidx=tidx+1;
end;

for type={'90','mi','adaboost'}
    resFile=sprintf('results-neg-%s',char(type));
    humFile=sprintf('results-neg-human');
    res=load(resFile,'det','tot','area');
    hum=load(humFile,'det','tot','area');
    figure(tidx);
    for n=1:NEYE
        for t=1:nTasks
            subplot(NEYE,nTasks,(n-1)*nTasks+t);
            errorbar(THRESH,mean(res.det{n,t}./res.tot{n,t}),std(res.det{n,t}./res.tot{n,t}),'r');hold on;
            errorbar(THRESH,mean(hum.det{n,t}./hum.tot{n,t}),std(hum.det{n,t}./hum.tot{n,t}),'g')
            axis([0 1 0 1]);
            legend('Model','Human')
            title(sprintf('Overlap:%.3f',mean(res.area{n,t})/mean(hum.area{n,t})));
        end;
    end; 
    set(gcf,'Name',[char(type) '-neg'])
    tidx=tidx+1;
end;

