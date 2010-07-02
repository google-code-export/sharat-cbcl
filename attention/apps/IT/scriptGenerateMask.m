clear all;
close all;
SETTINGS='settings';

load(fullfile(SETTINGS,'set-001'),'gSettings','tstTag');
%-------------------------------------------------
%set up the mask
H=600;
R=5.5*40; %5.5 degree visual angle
SZ=128;
scales=logspace(log10(SZ/2),log10(4*SZ),16)
cx=[H/2+R H/2+R*cos(pi/3) H/2+R*cos(-pi/3)]
cy=[H/2   H/2-R*sin(pi/3) H/2+R*sin(pi/3)]
mask={}
%-------------------------------------------------------
%generate mask
%
for s=1:length(scales)
    for i=1:3
        msk=zeros(H,H);
        [x,y]=meshgrid(1:H,1:H);
        x=x-cx(i);y=y-cy(i);
        sigma=scales(s);
        msk=exp(-(x.^2+y.^2)/(2*sigma*sigma));
        mask{i,s}=msk;
        %imagesc(msk,[0 1]);title(sprintf('Scale:%f,position:%d',scales(s)/(SZ),i))
        %pause(0.5);
    end;    
end;    
%----------------------------------------------------------
%generate features
for i=1:length(gSettings)
    setFile=fullfile(SETTINGS,sprintf('set-%03d',i));
    ftrFolder=fullfile(SETTINGS,sprintf('ftr-%03d',i));
    lockFile=fullfile(SETTINGS,sprintf('lock-%03d.mat',i));
    tstMX=cell(size(mask,1),size(mask,2));
    if(exist(lockFile))
        continue;
    end;
    save(lockFile,'lockFile');
    load(setFile,'gSettings','tstTag');
    load(fullfile(ftrFolder,tstTag{1}),'ftr');
    [ht,wt,depth]=size(ftr{2});
    nFtr         =length(ftr{3});
    for p=1:3
        for s=1:length(scales)
            tstMX{p,s}=zeros(length(tstTag),nFtr);
            msk=imresize(mask{p,s},[ht,wt],'bicubic');
            for f=1:length(tstTag)
                    fprintf('Processing setting:%d,file %d of %d\n',i,f,length(tstTag));
                    ftrFile=fullfile(ftrFolder,tstTag{f});
                    load(ftrFile,'img','ftr');
                    for d=1:depth
                        plane=msk.*ftr{2}(:,:,d);
                        tstMX{p,s}(f,d)=max(plane(:));
                    end;
            end;%end f
        end;%s            
    end;%p
    save(setFile,'tstMX','-append');
end;    

