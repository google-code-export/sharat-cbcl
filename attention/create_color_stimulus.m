function out=create_color_stimulus(array,carray,NDIR,RF,cellSize)
    gabors   =getGabors(RF,NDIR);
	lPad     =floor((cellSize-RF)/2);
	rPad     =cellSize-RF-lPad;
	[aht,awt]=size(array);
	out      =zeros(cellSize*aht,cellSize*awt,3);
	for c=1:3
	for i=1:aht
		for j=1:awt
		  if(array(i,j)>0)
			[x,y]  = meshgrid(0:RF-1,0:RF-1);
			[th,r] = cart2pol(x-RF/2,y-RF/2);
			cell   = img_scale(gabors(:,:,array(i,j))).*(r<=ceil(RF/2));
			cell   = padarray(cell,[lPad rPad],'both');
			out((i-1)*cellSize+[1:cellSize],(j-1)*cellSize+[1:cellSize],c)=cell*(carray(i,j)==c| carray(i,j)==0);
		  end;
		end;
	end;
	out(:,:,c)=img_scale(out(:,:,c));  
	end;
%end function
