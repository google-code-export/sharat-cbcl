function [dset,dnorm] = imgset_to_dset(img,dsz)
	dset={};
    dnorm=[];
	if(~isfloat(img))img=im2double(img);end;
	%extract patches
	blksz=ceil(dsz*0.5);
	[ht,wt,dim]=size(img);
	idx  =1;
	for y=1:blksz:ht-dsz+1
		for x=1:blksz:wt-dsz+1
			dset{idx}=img(y:y+dsz-1,x:x+dsz-1,:);
            dnorm(idx)=norm(dset{idx}(:));
			idx      =idx+1;
		end;
	end;
%end;
