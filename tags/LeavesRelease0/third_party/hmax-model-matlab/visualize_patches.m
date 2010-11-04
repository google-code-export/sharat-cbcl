%---------------------------------------------
%visualizes C1 patches
%
%sharat@mit.edu
%--------------------------------------------
function visualize_patches(patches,doMax)
load patches_gabor;
N    =length(patches);
for i=1:N
	 rowPatch=[];
	 for y=1:size(patches{i},1)
	   colPatch=[];
	   for x=1:size(patches{i},2)
		 blk=zeros(size(patches_gabor{1}));
		 [val,maxIdx]=max(patches{i},[],3);
		 if(~doMax)
		   for z=1:size(patches{i},3)
			 blk=blk+patches{i}(y,x,z)*patches_gabor{z};
		   end;
		 else
		   blk=patches_gabor{maxIdx(y,x)};
		 end;
		 colPatch=cat(2,colPatch,blk);
	   end;
	   rowPatch=cat(1,rowPatch,colPatch);
	 end;
	 nrows=ceil(sqrt(N));ncols=nrows;
	 subplot(nrows,ncols,i);imagesc(rowPatch);axis off;colormap('gray');
end;
