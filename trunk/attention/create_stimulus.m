function out=create_stimulus(array,NDIR,RF,cellSize)
    gabors   =getGabors(RF,NDIR);
	lPad     =floor((cellSize-RF)/2);
	rPad     =cellSize-RF-lPad;
	[aht,awt]=size(array);
	out      =zeros(cellSize*aht,cellSize*awt);
	for i=1:aht
		for j=1:awt
		  if(array(i,j)>0)
			cell = gabors(:,:,array(i,j));
			cell = padarray(cell,[lPad rPad],'both');
		  	out((i-1)*cellSize+[1:cellSize],(j-1)*cellSize+[1:cellSize])=cell;
		  end;
		end;
	end;
%end function
