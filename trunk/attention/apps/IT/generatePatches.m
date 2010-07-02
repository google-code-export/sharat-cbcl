%------------------------------------------------
%
%
clear all;
pidx=0;
patches={};
for d1=0:4
  for d2=0:4
	for d3=0:4
	  for d4=0:4
		patch        =zeros(2,2,4);
		if(d1) patch(1,1,d1)=1;end;
		if(d2) patch(1,2,d2)=1;end;
		if(d3) patch(2,1,d3)=1;end;
		if(d4) patch(2,2,d4)=1;end;
		pidx=pidx+1
		patches{pidx}=patch;
		%for i=1:4
		%  subplot(1,4,i);imagesc(patch(:,:,i));axis image off
		%end;
		%drawnow;pause(0.1);
	  end;
	end;
  end;
end;
save universal_dictionary patches;

	
