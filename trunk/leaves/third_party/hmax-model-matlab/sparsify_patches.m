%-------------------------------------------------------------------
%
%sharat@mit.edu
%-------------------------------------------------------------------
function spatches = sparsify_patches(patches)
	spatches = cell(size(patches));
	for i=1:length(patches)
		p        = patches{i};
		[val,idx]= max(p,[],3);
		sp       = zeros(size(p));
		for x=1:size(p,2)
		  for y=1:size(p,1)
		     sp(y,x,idx(y,x))=p(y,x,idx(y,x));
		  end;
		end;
		spatches{i}=sp;
	end;
%end function
