%------------------------------------------------------------------------
%Compares the original matlab implementation http://cbcl.mit.edu
%with the current implementation
%
%sharat@mit.edu
%-----------------------------------------------------------------------
function compare_versions 
%------------
%paths
STDMODELPATH='~/third_party/standardmodel';
STMPATH     ='~/stm';
addpath(genpath(STDMODELPATH));
addpath(genpath(STMPATH));
warning('off','all');
%---------------
%image
img         = imread('cameraman.tif');
img         = im2double(img);

%----------------------
%settings for STDMODEL
%---------------------
rot = [90 -45 0 45];
c1ScaleSS = [1:2:18];
RF_siz    = [7:2:39];
c1SpaceSS = [8:2:22];
minFS     = 7;
maxFS     = 39;
div = [4:-.05:3.2];
Div       = div;

%-------------------
%extract patches
%
%------------------
%prepare patches
stdPatches              = extractRandC1Patches({flipud(img),fliplr(img),rot90(img),...
                                                rot90(img,3)},1,200,4);
stdPatches              = stdPatches{1};
%------------------
%prune patches
%patchNorm               = sum(stdPatches.^2);
%[patchValues,patchIdx]  = sort(patchNorm,'descend');
%stdPatches              = stdPatches(:,patchIdx(1:100));
fprintf('Initializing gabor filters -- full set');
%-----------------------------------
%baseline version
tic;
[fSiz,filters,c1OL,numSimpleFilters] = init_gabor(rot, RF_siz, Div);
[stdC2,stdS2,stdC1,stdS1]            = C2(img,filters,fSiz,c1SpaceSS,c1ScaleSS,c1OL,stdPatches);
toc;

%-----------------------------------
%new version
tic;
c0Patches     = stdFilters2stmFilters(filters,fSiz);
c1Patches     = stdPatches2stmPatches(stdPatches,4);
stmC0         = create_c0(img,1.1133,16);
stmS1         = s_norm_filter(stmC0,c0Patches);
stmC1         = c_local(stmS1,8,3,2,2);
stmS2         = s_grbf(stmC1,c1Patches,sqrt(1/2));
stmC2         = c_global(stmS2);
toc;

%--------------------------------------
%compare
stmC2         =-log(stmC2+eps);
plot(stdC2,stmC2,'.');
display('Result of correlation')
corrcoef(stdC2,stmC2)
save comp stdS1 stdC1 stdS2 stdC2 stmS1 stmC1 stmS2 stmC2 c0Patches;



function stmFilters=stdFilters2stmFilters(filters,fSiz)
    stmFilters=cell(4,1);
    for i=1:4
        stmFilters{i}=reshape(filters(1:fSiz(i)^2,i),[fSiz(i) fSiz(i)]);
    end;

function stmPatches=stdPatches2stmPatches(stdPatches,sz)
    stmPatches=cell(size(stdPatches,2),1);
    for i=1:length(stmPatches)
        stmPatches{i}=reshape(stdPatches(:,i),[sz sz 4]);
    end;


%end
