function dset = imgset_to_dset_color(img,dsz)
	dset={};
	%normalize image
	if(~isfloat(img))img=im2double(img);end;
	%extract patches
	blksz      =ceil(dsz*0.5);
	[ht,wt,dim]=size(img);
	idx  =1;
	for y=1:blksz:ht-dsz+1
		for x=1:blksz:wt-dsz+1
			dset{idx}=imcrop(img,[x y dsz-1 dsz-1]);
			idx      =idx+1;
		end;
	end;
%end;
