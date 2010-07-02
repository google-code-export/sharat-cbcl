clear all;
SETTINGS='settings';
addpath(genpath('~/third_party/BNT'));
addpath(genpath('~/utils'));
jtree_inf_engine(mk_bnet(zeros(2),[1 1]));
load(fullfile(SETTINGS,'set-009'),'gSettings','tstTag','tstY');
%-------------------------------------------------
%set up the mask
H=600;
R=5.5*40; %5.5 degree visual angle
SZ=128;
scales=logspace(log10(SZ/16),log10(4*SZ),16)
cx=[H/2+R H/2+R*cos(pi/3) H/2+R*cos(-pi/3)]
cy=[H/2   H/2-R*sin(pi/3) H/2+R*sin(pi/3)]
mask={}
%-------------------------------------------------------
%generate mask
%
for s=1;%1:length(scales)
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
    ftr{2}=c_resize({ftr{2}},16,16);ftr{2}=ftr{2}{1};
    ftr{2}=ftr{2}(:,:,sel);
	[ht,wt,depth]=size(ftr{2});
    nFtr         =length(sel);
	%-------------------------------------------------
	%change pO
    pO=pO(:,1:16);
	pO=max(0.5,min(0.9,pO));
    if(~exist('en-test.mat'))
        engine=buildEngine({[ht,wt]},1,0.01,pO);
        save('en-test','engine');
    else
        load('en-test','engine');
    end;
	F_start=2;C_start=F_start+depth;L=2;
	EPS=0.1;
    tstO=zeros(4,length(tstTag),16);	
    tstTag=tstTag(randperm(length(tstTag)));
    for f=1:length(tstTag)
	  if(str2num(tstTag{f}(1))==0)continue;end;
      fprintf('Processing setting:%d,file %d of %d\n',i,f,length(tstTag));
      ftrFile=fullfile(ftrFolder,tstTag{f});
      load(ftrFile,'img','ftr');
      ftr{2}=c_resize({ftr{2}},16,16);ftr{2}=ftr{2}{1};
      ftr{2}=ftr{2}(:,:,sel);
      figure(1);imagesc(img);axis image off;colormap('gray');
	  for p=1:4
        for s=1:length(scales)
                    msk=imresize(mask{p,s},[ht,wt],'bilinear');
                    if(p~=4)
    				    %msk=msk>quantile(msk(:),0.98);
                    end;
			        evidence=cell(C_start+depth,1);
                    fprintf('Scale:%d,pos:%d\n',s,p);
                    %evidence{1}=eps*ones(1,16);evidence{1}(tstY(f))=1;
					evidence{L}=msk(:);%/(sum(msk(:))+eps);
                    for d=1:nFtr
                        plane=ftr{2}(:,:,d);
                        evidence{C_start+d}=[max(plane(:)>thresh(d),EPS/(ht*wt));EPS];
                    end;    
                    engine=enter_evidence(engine,cell(C_start+depth,1),'soft',evidence);
                    m=marginal_nodes(engine,2) 
                    figure(2);
 					subplot(3,4,p);imagesc(log(msk),[-20 0]);
					subplot(3,4,p+4);imagesc(log(reshape(m.T,16,16)),[-20 0]);
                    m=marginal_nodes(engine,1);
					subplot(3,4,p+8);
                    num=sscanf(tstTag{f}(2:end),'%02d%02d%02d') ;
                    bar(m.T);title(sprintf('%d,%d,%d-%d-%d',p,s,num));drawnow;
		    end;%end s
            tstO(f,p,:)=m.T(:);
        end;%p
        pause;
   end;%f     
end;%i   
save tstResults tstO;
