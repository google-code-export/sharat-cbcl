%--------------------------------------------------------------------
%
%sharat@mit.edu
%
function script_illumination_features
HOME        ='/cbcl/cbcl01/sharat';
DHOME       ='/cbcl/scratch04/sharat/data/AIMC2Clustered';
DESTHOME    ='/cbcl/scratch04/sharat/data/AIMC2ClusteredEx';%extended
if(~exist(DESTHOME))
    mkdir(DESTHOME);
end;

addpath(fullfile(HOME,'lgn'));
addpath(fullfile(HOME,'utils'));
addpath(fullfile(HOME,'cbcl-model-matlab'));
addpath(fullfile(HOME,'ssdb'));
%------------------------------
%
load patches_gabor;
h                   =fspecial('gaussian',17,3);
[gx,gy]             =gradient(h);
[gxx,gxy]           =gradient(gx);
[gyx,gyy]           =gradient(gy);
h                   =gxx+gyy;
h                   =(h-mean(h(:)));
h                   =h/norm(h(:));
patches_gabor{end+1}= h;
dataFiles   =dir(fullfile(DHOME,'C2*.mat'));
for i=1:length(dataFiles)
    fprintf('Processing file:%d of %d\n',i,length(dataFiles));
    load(fullfile(DHOME,dataFiles(i).name));
    img = im2double(imread(img_file));
    img = imresize(img,[256 340],'bicubic');
    lab = applycform(img,makecform('srgb2lab'));
    figure(99);imagesc(max(0,min(1,img)));axis image;
    figure(100);
    for c=1:3;
        subplot(1,3,c);imagesc(img_scale(lab(:,:,c)));axis image;
        colormap('gray');
    end;
    ftrl= callback_intensity(lab(:,:,1),16);
    ftra= callback_intensity(lab(:,:,2),16);
    ftrb= callback_intensity(lab(:,:,3),16);
    ftrl= c_local(ftrl{2},8,3,2,2);
    ftra= c_local(ftra{2},8,3,2,2);
    ftrb= c_local(ftrb{2},8,3,2,2);

    for b=1:length(ftrl)
        figure(b);
        subplot(1,3,1);imagesc(vec2Color(ftrl{b}));colorbar;axis image;
        subplot(1,3,2);imagesc(vec2Color(ftra{b}));colorbar;axis image;
        subplot(1,3,3);imagesc(vec2Color(ftrb{b}));colorbar;axis image;
        ftrl{b}   =imresize(ftrl{b},[size(ftr{2}{b},1),size(ftr{2}{b},2)],'bicubic');
        ftr{2}{b} =cat(3,ftr{2}{b},ftrl{b},ftra{b},ftrb{b});
    end;
    pause(1);
    save(fullfile(DESTHOME,dataFiles(i).name),'ftr','lbl','img_file');
 end;

function ftr=callback_intensity(img,nLevels)
    c0=create_c0(img,1.1133,nLevels);
    for b=1:length(c0)
        plane=c0{b};
        plane=(plane-mean(plane(:)))/(std(plane(:))+0.001);
        [pos,neg]=pos_neg(plane);
        clr{b}   =cat(3,pos,neg);
    end;
    ftr{1}=clr;
    ftr{2}=c_local(clr,8,3,2,2);

function ftr=callback_c1(img,c0patches,nLevels)
    if(size(img,3)==3)
      img = rgb2gray(img);
    end;
    img     = im2double(img);
    if(nargin<3)
        nLevels=16;
    end;
    %----------------------
    %
    %----------------------
    c0      =   create_c0(img,1.1133,nLevels);
    s1      =   s_norm_filter(c0,c0patches);
    psz     =   size(c0patches{1},1);
    c1      =   c_local(s1,8,3,2,2);
    %format the outputs
    ftr{1}       = s1;
    ftr{2}       = c1;
    ftr_names{1} = {'empty','C1'};
    ver          = 1;
%end function

