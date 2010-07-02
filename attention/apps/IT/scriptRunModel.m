clear all;
close all;
SETTINGS='settings';
addpath(genpath('~/third_party/BNT'));
addpath(genpath('~/utils'));
jtree_inf_engine(mk_bnet(zeros(2),[1 1]));
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
for s=6;%1:length(scales)
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
    mask{4,s}=ones(size(mask{3,s}));
end;    
%----------------------------------------------------------
%generate features
for i=9:9;%length(gSettings)
    setFile=fullfile(SETTINGS,sprintf('set-%03d',i));
    ftrFolder=fullfile(SETTINGS,sprintf('ftr-%03d',i));
    lockFile=fullfile(SETTINGS,sprintf('lock-model-%03d.mat',i));
    tstMX=cell(size(mask,1),size(mask,2));
    if(exist(lockFile))
        %continue;
    end;
    save(lockFile,'lockFile');
    load(setFile,'gSettings','tstTag','thresh','sel','pO');

    load(fullfile(ftrFolder,tstTag{1}),'ftr');
    ftr{2}=ftr{2}(:,:,sel);
	[ht,wt,depth]=size(ftr{2});
    nFtr         =length(sel);
	%-------------------------------------------------
	%change pO
    pO=pO(:,1:16);
	pO=max(0.5,min(0.9,pO));
    if(~exist('en2.mat'))
        engine=buildEngine({[ht,wt]},ceil(ht/8),0.01,pO);
        save('en2','engine');
    else
        load('en2','engine');
    end;
	F_start=2;C_start=F_start+depth;L=2;
	EPS=0.01;
	
    for p=1:4
        for s=6;%1:length(scales)
            tstO{p,s}=zeros(length(tstTag),16);
            msk=imresize(mask{p,s},[ht,wt],'bicubic');
            lockFile=sprintf('2%02d_%02d.lock',p,s);
            saveFile=sprintf('tst2O_%02d_%02d',p,s);
            if(exist(lockFile))
                continue;
            else
                save(lockFile,'lockFile');
            end;    
            for f=1:length(tstTag)
			        evidence=cell(C_start+depth,1);
                    fprintf('Scale:%d,pos:%d\n',s,p);
                    fprintf('Processing setting:%d,file %d of %d\n',i,f,length(tstTag));
                    ftrFile=fullfile(ftrFolder,tstTag{f});
                    load(ftrFile,'img','ftr');
                    evidence{L}=msk(:)/sum(msk(:)+eps);
                    ftr{2}=ftr{2}(:,:,sel);
					for d=1:depth
					  plane=ftr{2}(:,:,d);
					  evidence{C_start+d}=[max(plane(:)>thresh(d),EPS/(ht*wt));EPS];
                    end;
                    engine=enter_evidence(engine,cell(C_start+depth,1),'soft',evidence);
                    m=marginal_nodes(engine,1);
                    tstO{p,s}(f,:)=m.T(:);
                    bar(m.T);title(tstTag{f});drawnow;
		    end;%end f
            save(saveFile,'tstO');
        end;%s     
   end;%p     
end;%i   
