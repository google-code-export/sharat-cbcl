clear all;
img = imread('cameraman.tif');
c0Patches=read_patches('c0Patches.txt');
c1Patches=read_patches('c1Patches.txt');
c1Time = [];
c2Time = [];
SIZES=[64,128]
for s=1:length(SIZES)
 img = imresize(img,[SIZES(s) SIZES(s)],'bilinear');
 c1Time(s)=0;c2Time(s)=0;
 for t=1:5
     fprintf('Size:%d, trial:%d\n',s,t)
     tic;
     c0=create_c0(img,1.113,12);s1=s_norm_filter(c0,c0Patches);
     c1=c_local(s1,8,3,2,2);
     c1Time(s)=c1Time(s)+toc;
     tic;
     s2=s_grbf(c1,c1Patches);
     c2=c_global(s2);
     c2Time(s)=c2Time(s)+toc;
     tic;
 end;
end;
