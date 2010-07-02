%---------------------------------------------------------
%
%sharat@mit.edu
%---------------------------------------------------------
function out = sparsify_dist(patch)
out          = patch; 
[ht,wt,d]  	= size(patch);
[pmax,pidx]	= max(patch,[],3);
out		   	= zeros(size(patch));
for i=1:d
	plane     =ones(ht,wt)*i;
	out(:,:,i)=exp(-(plane-pidx).^2/4);
end;
	
