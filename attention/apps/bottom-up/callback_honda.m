%---------------------------------------------------------
%
%sharat@mit.edu
%
function ftr=callback_honda(img)
HOME='/cbcl/cbcl01/sharat'
addpath(fullfile(HOME,'cbcl-model-matlab'));
addpath(fullfile(HOME,'lgn'));
addpath(fullfile(HOME,'utils'));
addpath(fullfile(HOME,'tisom'));
load patches_gabor; %has 11x11 gabor filters
lPatches=load('patches_clustered_1'); 
aPatches=load('patches_clustered_2');
bPatches=load('patches_clustered_3');
patches ={lPatches.patches,aPatches.patches,bPatches.patches};

c1Pool   =8;
doSN     =0;
lab      =applycform(img,makecform('srgb2lab'));
c2out    ={};for b=1:4;c2out{b}=[];end;
c1out    ={};for b=1:8;c1out{b}=[];end;
for c=1:3
    img=imresize(lab(:,:,c),[256 340],'bicubic');
    c0 = create_c0(img,sqrt(sqrt(2)),16);
    s1 = s_norm_filter(c0,patches_gabor);
    if(doSN)
      s1 = s_dn(s1);
    end;      
    c1 = c_local(s1,8,3,2,2);
    for b=1:length(c1)
        c1out{b}=cat(3,c1out{b},c1{b});
    end;        
    s2 = s_grbf(c1,patches{c});
    c2 = c_local(s2,8,3,2,2);
    for b=1:length(c2)
        c2out{b}=cat(3,c2out{b},c2{b});
    end;
end;
c2b    = c_terminal(c2out);
ftr    = {c1out,c2out,c2b}

