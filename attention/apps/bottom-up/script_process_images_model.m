%-------------------------------------------------------------------------
%
%sharat@mit.edu
%-------------------------------------------------------------------------
C2DIR  ='/cbcl/scratch04/sharat/data/AIMC2ClusteredEx';
DESTDIR='/cbcl/scratch04/sharat/data/AIMBU90ClusteredRerun'
MFILE  ='prob_model_aim';
if(~exist(DESTDIR))
    mkdir(DESTDIR)
end;    
fprintf('loading files\n');
load patches_clustered;
load aim_model_90Clustered;
load origfixdata;
fprintf('done\n')
pnorm=zeros(1,length(patches));
for p=1:length(patches)
 pnorm(p)=norm(patches{p}(:));
end;
[pnorm,idx]=sort(pnorm,'descend');
%-----------------------------------
%define CPT
sel =[idx(1:32),65:70];
SIZE=[16 22];
th  =model.thresh(sel);
pO  =0.5*ones(length(sel),1);%1-model.qtl(sel);pO=pO(:);
%-----------------------------------
%build model
fprintf('Buidling model...\n')
if(~exist(MFILE))
    engine=buildEngine({SIZE},0.5,0.1,pO);
end;
fprintf('done');

c2Files=dir(fullfile(C2DIR,'C2_0*.mat'));
for i=1:length(c2Files)
    fprintf('Processing %d of %d\n',i,length(c2Files));
    load(fullfile(C2DIR,c2Files(i).name),'ftr','img_file');
    [path,name,ext]=fileparts(img_file);
    imgID          =sscanf(name,'%d');
    [ypos,xpos]    =find(white{imgID});
    %---------------------
    %reduce to single band
    ftr{2}  =ftr{2}(1:end);
    ftr{2}  =c_local(ftr{2},1,1,length(ftr{2}),length(ftr{2}));
    c2      =ftr{2}{1}(:,:,sel);
    c2      =transformMap(c2,th);
    c2      =imresize(c2,SIZE,'bicubic');
    %----------------------
    %enter evidence
    NFTR     =length(sel);
    sevidence=cell(2+2*NFTR,1);
    evidence =cell(2+2*NFTR,1);
    C_start  =2+NFTR;
    L        =2;
    for f=1:NFTR
	    plane               =c2(:,:,f);
        sevidence{C_start+f}=[plane(:);0.05];
    end;
    %------------------------------
    %add center bias
    [x,y] = meshgrid(1:SIZE(2),1:SIZE(1));
    pL    = exp(-(x-SIZE(2)/2).^2/(2*SIZE(2).^2/8)...
                -(y-SIZE(1)/2).^2/(2*SIZE(1).^2/8));
    sevidence{L}=pL(:);
    engine= enter_evidence(engine,evidence,'soft',sevidence);
    map   = marginal_nodes(engine,[2]);map=log(map.T);
    map   = reshape(map,SIZE);
    img     =imresize(im2double(imread(img_file)),0.5,'bicubic');
    figure(1);
    subplot(1,2,1);imagesc(max(0,min(1,img)));
    axis image off;hold on;
    plot(xpos/2,ypos/2,'g+');hold off;
    subplot(1,2,2);imagesc(map);
    salFile        =fullfile(DESTDIR,[name '.mat']);
    salmap         =map;
    save(salFile,'salmap','img_file');
    pause(1);
end;
