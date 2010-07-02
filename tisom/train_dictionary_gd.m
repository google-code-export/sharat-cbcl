%-------------------------------------------------------------------------
%
%sharat@mit.edu
%-------------------------------------------------------------------------
function model = train_dictionary_gd(img_set,dsz,filtsz,nfilt,MAXITER)
	if(nargin<5)
		MAXITER = 10;
	end;
	%-----------------------------------
	%get all patches
	dset = {};
	for i=1:length(img_set)
		dset=cat(2,dset,imgset_to_dset(img_set{i},dsz));
	end;
	fprintf('Patches:%d\n',length(dset));
	idx  = randperm(length(dset));
	dset = dset(idx(1:min(length(dset),60000)));		
	clear img_set;
	%-----------------------------------
	%initialize filters
	for i=1:nfilt
		filt{i}=0.1*randn(filtsz);
	end;
	%-------------------------------
	%initalize som parameters
	dsigma = nfilt/8;dstep=0.05;	
	lrate  = 0.1;lstep = 0.05;		
 	for iter = 1:MAXITER
		fprintf('Iteration:%d\n',iter);
		fprintf('Learning rate:%f\n',lrate);
		fprintf('Neighborhood:%f\n',dsigma);
		for p=1:length(dset)
			mxval=-inf;mxidx=1;mxi=1;mxj=1;
			%------------------
			%find out the winner	
			
			for f=1:nfilt
			    den    = conv2(ones(filtsz,1),ones(filtsz,1),dset{p}.^2,'valid');
				den    = sqrt(den*sum(filt{f}(:).^2)+eps);
				num    = conv2(dset{p},filt{f}(end:-1:1,end:-1:1),'valid');
				out    = num./den;
				mx     = max(out(:));
				[mi,mj]= find(out==mx,1);
				if(mx>mxval)
					mxval  = mx;
					mxidx  = f;
					mxi    = mi; 
					mxj	   = mj;
				end;
			end;
			%----------------------------
			%update winning filter
			mxcrop = imcrop(dset{p},[mxj mxi filtsz-1 filtsz-1]);
			if(any(size(mxcrop)~=[filtsz filtsz])) 
				fprintf('X');
				continue;
			end;
			if(mod(p,100)==0) fprintf('*');end;
			for f=1:nfilt
				dist   =(f-mxidx);%min(abs(f-mxidx),nfilt-abs(f-mxidx));
				distval=exp(-(dist*dist)/(2*dsigma*dsigma));
				distval=distval*(1-dist^2/(dsigma*dsigma));
				filt{f}=filt{f}+lrate*distval*(mxcrop-filt{f});	
			end;%f
		end;%dataset
		fprintf('\n');
		%--------------------
	    %update learning rate and sigma
		dsigma = exp(log(dsigma)-dstep);
		lrate  = exp(log(lrate)-lstep);		
		for f=1:length(filt)
			subplot(4,ceil(length(filt)/4),f);imagesc(filt{f});
		end;
		drawnow;
	end;%iter
	model.filters = filt;
	model.dsz     = dsz;
%end function


