%----------------------------------------------------------------------------------------------------------------------
%
%sharat@mit.edu
%----------------------------------------------------------------------------------------------------------------------
function out=local_hist(map,thresh,pool)
 out = cell(length(map),1);
 %get max
 for b = 1:length(map)
	[ht,wt,d]      =size(map{b});
	out{b}         =zeros(ht,wt,d+1);
	[maxmap,idxmap]=max(map{b},[],3);
 	idxmap(maxmap<thresh)=0;
	for val  = 0:size(map{b},3)
		tmap = double(idxmap==val);
	    tmap = conv2(ones(pool,1),ones(pool,1),tmap,'same'); 	
		out{b}(:,:,val+1)=tmap;
	end;
    %normalize counts
    skip   = floor(pool/2);
	smap   = sum(out{b},3);
	out{b} = out{b}./(repmat(smap,[1 1 d+1]));
	out{b} = out{b}(1:skip:end,1:skip:end,:);
end;  	
%end function
