%-------------------------------------------------------------------------
%
%sharat@mit.edu
%-------------------------------------------------------------------------
function script_process_images
C2DIR  ='/cbcl/scratch04/sharat/data/AIMC2ClusteredEx';
DESTDIR='/cbcl/scratch04/sharat/data/AIMBU90Clustered'
if(~exist(DESTDIR))
    mkdir(DESTDIR)
end;    
load patches_clustered;
load aim_model_90Clustered;
pnorm=zeros(1,length(patches));
for p=1:length(patches)
 pnorm(p)=norm(patches{p}(:));
end;
[pnorm,idx]=sort(pnorm,'descend');

c2Files=dir(fullfile(C2DIR,'C2_0*.mat'));
for i=1:length(c2Files)
    load(fullfile(C2DIR,c2Files(i).name),'ftr','img_file');
    %----------------------
    %update the model
    if(0)
    for p=1:size(ftr{2}{1},3)
        X=[];
        for b=1:length(ftr{2})
            plane=ftr{2}{b}(:,:,p);
            X=cat(1,X,plane(:));
        end;
        model.thresh(p)=quantile(X,0.9);
        model.qtl(p)   =0.9;
    end;
    end;
    ftr{2}  =ftr{2}(2:end);
    ftr{2}  =c_local(ftr{2},1,1,length(ftr{2}),length(ftr{2}));
    mapcolor=bu_map(ftr{2},model,[105:1:115]);
    mapshape=bu_map(ftr{2},model,idx(1:16));
    mapboth =bu_map(ftr{2},model,[idx(1:16),105:1:115]);
    mapboth{1}=imfilter(mapboth{1},fspecial('gaussian'));
    scales  =exp(mean(log(reshape(1.1133.^[0:15],4,4))));
    scales  =scales(2:end);
    dlcolor =find_fixation_points(mapcolor(1:end),scales(1:end));
    dlshape =find_fixation_points(mapshape(1:end),scales(1:end));
    dlboth  =find_fixation_points(mapboth(1:end),scales(1:end));
    img     =imresize(im2double(imread(img_file)),0.5,'bicubic');
    figure(1);
    subplot(2,2,1);imagesc(max(0,min(1,img)));axis image off;
    subplot(2,2,2);imagesc(mapcolor{1});plot_points(img,dlcolor,5);title('Color')
    subplot(2,2,3);imagesc(mapshape{1});plot_points(img,dlshape,5);title('Shape')
    subplot(2,2,4);imagesc(mapboth{1});plot_points(img,dlboth,5);title('Color+Shape')
    figure(2);
    subplot(2,2,1);imagesc(max(0,min(1,img)));axis image off;
    subplot(2,2,2);imagesc(mapcolor{1});title('Color')
    subplot(2,2,3);imagesc(mapshape{1});title('Shape')
    subplot(2,2,4);imagesc(mapboth{1});title('Color+Shape');
 
    [path,name,ext]=fileparts(img_file);
    salFile        =fullfile(DESTDIR,[name '.mat']);
    salmap         =mapboth{1};
    save(salFile,'salmap','img_file');
    %saveas(gcf,fullfile(DESTDIR,[name '.jpg']));
    pause(1);
end;

function plot_points(img,dl,npoints)
    imagesc(max(0,min(1,img)));axis image off;hold on;
    [ht,wt,d] = size(img);
    for i=1:min(length(dl),npoints)
        x=dl(i).pos(1)*wt;
        y=dl(i).pos(2)*ht;
        sz=dl(i).s*30;
        box=[x-sz/2 y-sz/2 sz sz];
        plot(x,y,'r+','markerSize',8,'lineWidth',2);
        rectangle('Position',box,'EdgeColor','red','lineWidth',1,'lineStyle','--');
    end;
    hold off;
%end;
