%---------------------------------------------------------
%
%sharat@mit.edu
%---------------------------------------------------------
function out = sparsify(patch,fraction)
out          = patch; 
if(nargin<2)
	fraction=1;
end;
[ht,wt,d]  	= size(patch);
[pmax,pidx]	= max(patch,[],3);
out		   	= zeros(size(patch));
for i=1:d
	out(:,:,i)=patch(:,:,i)>=fraction*pmax;
end;
	
