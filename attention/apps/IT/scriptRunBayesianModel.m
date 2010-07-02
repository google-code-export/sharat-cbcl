%---------------------------------------------------------------------------------
%
%sharat@mit.edu
%---------------------------------------------------------------------------------
SETTINGS='settings';
addpath(genpath('~/third_party/BNT'));
addpath(genpath('~/utils'));
addpath(genpath('~/cbcl-model-matlab'));
jtree_inf_engine(mk_bnet(zeros(2),[1 1]));
%load(fullfile(SETTINGS,'set-009'),'gSettings','tstTag','tstY');
%-------------------------------------------------
%set up the mask
H=600;
R=5.5*40; %5.5 degree visual angle
SZ=128;
scales=logspace(log10(0.125*SZ),log10(4*SZ),8);
%------------------------
%binary noise probability
noise=linspace(0,0.5,8);
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
    end;    
    %no mask condition
    mask{4,s}=ones(size(mask{3,s}));
end;    
keyboard;
%--------------------------------------------------------
%for each setting of attention mask and noise get readout
%----------------------------------------------------------
for i=1:9;
    setFile=fullfile(SETTINGS,sprintf('set-%03d',i));
    ftrFolder=fullfile(SETTINGS,sprintf('ftr-%03d',i));
    engFile=fullfile(SETTINGS,sprintf('engine-%03d.mat',i))
    load(setFile,'gSettings','tstTag','thresh','sel','pO');
    load(fullfile(ftrFolder,tstTag{1}),'ftr');
    ftr{2}=c_resize({ftr{2}},16,16);ftr{2}=ftr{2}{1};
    ftr{2}=ftr{2}(:,:,sel);
	[ht,wt,depth]=size(ftr{2});
    nFtr         =length(sel);
	%-------------------------------------------------
	%change pO
    pO=pO(:,1:16);
	pO=max(0.5,min(0.9,pO)); %generates sparsity
    if(~exist(engFile))
        engine=buildEngine({[ht,wt]},1,0.01,pO,'jtree');
        save(engFile,'engine');
    else
        load(engFile,'engine');
    end;
	F_start=2;C_start=F_start+depth;L=2;
    %-----------
    %important to keep EPS @ 0.1
	EPS=0.1;
    %---------------------------------------------------
    %posterior probabilities are maintained in tstO
    %tstO: nImages x nObj x nCond
    %conditions: 1=attention, 2=no attention
    tstO=zeros(length(tstTag),16,2);
    for s=1:length(scales)
        for n=1:length(noise)
             lockFile=fullfile(SETTINGS,sprintf('engine-%03d-%03d-%03d.lock',i,s,n));
             resFile=fullfile(SETTINGS,sprintf('results-%03d-%03d-%03d',i,s,n));
             if(exist(lockFile))
                 continue;
                 fprintf('Param:%d,%d,%d already being processed',i,s,n);
             else
                 save(lockFile,'lockFile');
             end;    
             %-------------------------
             %process each file
             for f=1:length(tstTag)
                  fprintf('Processing setting:%d,file %d of %d\n',i,f,length(tstTag));
                  ftrFile=fullfile(ftrFolder,tstTag{f});
                  load(ftrFile,'img','ftr');
                  %---------------------------------
                  %resize to 16x16 to reduce computational complexity
                  ftr{2}=c_resize({ftr{2}},16,16);ftr{2}=ftr{2}{1};
                  ftr{2}=ftr{2}(:,:,sel);
                  figure(1);imagesc(img);axis image off;colormap('gray');
                  %-----------------------------------------
                  %attention condition
                  tstCond=str2num(tstTag{f}(1));
                  if(tstCond)
                            msk=imresize(mask{tstCond,s},[ht,wt],'bilinear');
                  else
                            msk=imresize(mask{4,s},[ht wt],'bilinear');
                  end;                        
                  evidence=cell(C_start+depth,1);
                  %-------------------------
                  %change spatial prior(attention)
                  evidence{L}=msk(:);
                  %------------------------
                  %enter evidence
                  for d=1:nFtr
                      plane=ftr{2}(:,:,d)>thresh(d);plane=plane(:);
                      %add noise
                      rndNoise=rand(length(plane),1)<noise(n);
                      plane=rndNoise.*(1-plane)+(1-rndNoise).*plane;
                      evidence{C_start+d}=[max(plane(:),EPS/(ht*wt));EPS];
                  end;    
                  engine=enter_evidence(engine,cell(C_start+depth,1),'soft',evidence);
                  %---------------
                  %location readout
                  m=marginal_nodes(engine,2) 
                  figure(2);
                  subplot(2,3,1);imagesc(log(msk),[-20 0]);axis image off;
                  subplot(2,3,2);imagesc(log(reshape(m.T,16,16)),[-20 0]);axis image;
                  %----------------
                  %identity readout
                  m=marginal_nodes(engine,1);
                  subplot(2,3,3);
                  bar(m.T);
                  tstO(f,:,1)=m.T(:);
                  %-----------------------------------------------
                  %no attention condition
                  evidence{L}=[];%no spatial prior
                  engine=enter_evidence(engine,cell(C_start+depth,1),'soft',evidence);
                  m=marginal_nodes(engine,2) 
                  subplot(2,3,4);imagesc(log(msk),[-20 0]);axis image off;
                  subplot(2,3,5);imagesc(log(reshape(m.T,16,16)),[-20 0]);axis image;
                  %-----------------
                  %ID readout
                  m=marginal_nodes(engine,1);
                  subplot(2,3,6);
                  num=sscanf(tstTag{f}(2:end),'%02d%02d%02d') ;
                  bar(m.T);title(sprintf('%d-%d-%d-%d',tstCond,num));drawnow;
                  tstO(f,:,2)=m.T(:);
                 end;%end f
                 save(resFile,'tstO');
            end;%n
       end;%s     
    end;%i   
