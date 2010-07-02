%----------------------------------------------
%
%shows how to use the CBCL object detector
%sharat@mit.edu
%

%load gabor
load patches_gabor;
%load image
DONORM=0;

%load car and pedestrian detector
if(~DONORM)
  load c1_filter_car; filt{1}=filter{1};
  load c1_filter_ped; filt{2}=filter{1};
else
  load c1_filter_car_norm; filt{1}=filter{1};
  load c1_filter_ped_norm; filt{2}=filter{1};
end;


FACTOR=1.1133.^2;
for imgname={'SSDB02151.JPG','SSDB02757.JPG'};
  img=imread(char(imgname));
  objs={'car','pedestrian'};
  signs=[1,-1]; %side effect of libsvm

  %run detector
  if(~DONORM)
	ftr=callback_scan_c1(img,filt,'callback_c1_baseline',12);
  else
	ftr=callback_scan_c1(img,filt,'callback_c1',12);
  end;  
  res=ftr{1};%detection maps
  
  for o=1:length(objs)
	figure(o);
	subplot(3,2,1);imagesc(img);axis image;
	for s=1:length(res{o})
	  subplot(3,2,s+1);imagesc(res{o}{s}.*signs(o));
	  title(sprintf('scale:%.3f X',FACTOR.^(s-1)));
	  axis image;colorbar;
	end;	
	set(gcf,'name',objs{o});
  end;
  disp('press any key to continue');
  pause;
end;  
