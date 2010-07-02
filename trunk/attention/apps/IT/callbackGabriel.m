%--------------------------------------------------------------
%
%
%sharat@mit.edu
%
function ftr=callbackGabriel(img,patches_gabor,patches,c1Pool,c2Pool,doSN)
addpath('~/cbcl-model-matlab');
c0 = create_c0(img,sqrt(sqrt(2)),4);
s1 = s_norm_filter(c0,patches_gabor);
if(doSN)
    s1=s_dn(s1);
end;    
c1 = c_local(s1,c1Pool,ceil(c1Pool/2),2,2);
s2 = s_grbf(c1,patches);
c2 = c_local(s2,c2Pool,ceil(c2Pool/2),2,2);
c1 = c_local(c1,c2Pool,ceil(c2Pool/2),2,2);
c0 = zscore(c0);
c0 = c_local(c0,c1Pool,ceil(c1Pool/2),2,2);
c0 = c_local(c0,c2Pool,ceil(c2Pool/2),2,2);
%merge
%c2  = c2{1};
c2  = cat(3,c2{1},c1{1},c0{1});
c2b = c_terminal({c2});
ftr = {c1,c2,c2b};

   
