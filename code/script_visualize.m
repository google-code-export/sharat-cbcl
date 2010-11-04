%-----------------------------------------------------------------
%
%sharat@mit.edu
%-----------------------------------------------------------------
HOME  ='/data/scratch/sharat/data';
FILE  ='tst_001_119';
IMGHOME='/data/scratch/sharat/leaves';
DIRS      = {'lgn-sparse-features'}
for dataset=1:length(DIRS)
%close all;
fprintf('processing:%s\n',DIRS{dataset});
FHOME=DIRS{dataset};
load(fullfile(HOME,FHOME,FILE),'ftr','img_file');
c1    = ftr{1}{1};
c2    = ftr{2}{1};
fullscreen = get(0,'ScreenSize');
figure(1);
fprintf('printing image');
set(gcf,'Position',[0 -50 fullscreen(3) fullscreen(4)])
imshow(img_file);drawnow;
print('-depsc',[FHOME '-img.eps']);
print('-djpeg100',[FHOME '-img.jpg']);
saveas(gcf,[FHOME '-img.fig']);
%--------------------------------------
%visualize c1
%--------------------------------------
ncols = 5;
nrows = ceil(size(c1,3)/ncols)
figure(2);
fprintf('\n printing c1');
set(gcf,'Position',[0 -50 fullscreen(3) fullscreen(4)])
for i=1:size(c1,3)
 subplot(nrows,ncols,i);
 imagesc(c1(:,:,i));axis off; axis image;
 set(gca,'CLim',[0 0.3]);
end;
print('-depsc',[FHOME '-c1.eps']);
print('-djpeg100',[FHOME '-c1.jpg']);
saveas(gcf,[FHOME '-c1.fig']);
%--------------------------------------
%visualize c2
%--------------------------------------
idx   = randperm(size(c2,3));
c2    = c2(:,:,idx(1:min(16,size(c2,3))));
ncols = 4;
nrows = ceil(size(c2,3)/ncols);
figure(3);
fprintf('\n printing c2');
set(gcf,'Position',[0 -50 fullscreen(3) fullscreen(4)])
for i=1:size(c2,3)
  subplot(nrows,ncols,i);
  imagesc(c2(:,:,i));axis off; axis image;
  set(gca,'CLim',[0 0.75]);
end;
print('-depsc',[FHOME '-c2.eps']);
print('-djpeg100',[FHOME '-c2.jpg']);
saveas(gcf,[FHOME '-c2.fig']);
end;
