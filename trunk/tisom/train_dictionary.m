%-------------------------------------------------------------------------
%trains a dictionary of image/feature patches using spatially invariant
%topological clustering--a topological variation of the algorithm suggested
%in Fukushima '80'
%
%img_set [IN]  a cell array containing training images from which a dictionary is learned
%              each image can be three dimensional (either color or feature map)
%dsz     [IN]  domain size: this is the size of the image within which a single feature of
%              size filtsz is assumed to be embedded
%filtsz  [IN]  size of the dictionary elements (<dsz) 
%nfilt   [IN]  size of the dictionary (arranged as a nfiltxnfilt grid)
%MAXITER [IN]  number of iterations
%Example:
%img=imfilter(imread('cameraman.tif'),fspecial('laplacian'));
%img_set{1}=img;
%model=train_dictionary(img_set,11,7,4,50); 
%for i=1:4*4
    %subplot(4,4,i);imagesc(imresize(imfilter(model.filters{i},fspecial('laplacian')),2));
%end;
%colormap('gray')
%
%will learn 4x4 set of patches of size 7x7 embedded within 11x11 domain
%will stop after 50 iterations.
%sharat@mit.edu
%-------------------------------------------------------------------------
function model = train_dictionary(img_set,dsz,filtsz,nfilt,MAXITER,CALLBACK)
	if(nargin<5)
		MAXITER = 10;
	end;
    if(nargin<6)
        CALLBACK='convdist';
    end;
	%-----------------------------------
	%get all patches
	dset = {};dnorm=[];
	for i=1:length(img_set)
        [tset,tnorm]=imgset_to_dset(img_set{i},dsz);
		[tmp,idx]= sort(tnorm,'descend');
		nTerms=min(length(tset),500);
		tset = tset(idx(1:nTerms));
		tnorm= tnorm(idx(1:nTerms));
		dset = cat(2,dset,tset);
        dnorm= cat(2,dnorm,tnorm);
	end;
    dim     =size(dset{1},3);
	fprintf('Patches:%d\n',length(dset));
    fprintf('Dimension:%d\n',dim);
	[tmp,idx]= sort(dnorm,'descend');
	dset = dset(idx(1:min(length(dset),5000)));		
	clear img_set;
	%-----------------------------------
	%initialize filters
	for i=1:nfilt
        for j=1:nfilt
		    filt{i,j}=0.001*rand(filtsz,filtsz,dim);
        end;
	end;
	%-------------------------------
	%initalize som parameters
	dsigma = nfilt/2;dstep=0.05;	
	lrate  = 0.05;lstep = 0.01;		
 	for iter = 1:MAXITER
		fprintf('Iteration:%d\n',iter);
		fprintf('Learning rate:%f\n',lrate);
		fprintf('Neighborhood:%f\n',dsigma);
		for p=1:length(dset)
			maxval=0;mfx=1;mfy=1;mxi=1;mxj=1;
			%------------------
			%find out the winner	
			for fx=1:nfilt
                for fy=1:nfilt
                    out    = feval(CALLBACK,dset{p},filt{fy,fx});
                    mx     = max(out(:));
                    [mi,mj]= find(out==mx,1);
                    if(mx>maxval)
                       maxval = mx;
                       mfx    = fx;
                       mfy    = fy;
                       mxi    = mi; 
                       mxj	  = mj;
                    end;
				end;
			end;
			%----------------------------
			%update winning filter
			mxcrop = dset{p}(mxi:mxi+filtsz-1,mxj:mxj+filtsz-1,:);
			if(size(mxcrop,1)~=filtsz | size(mxcrop,2)~=filtsz) 
				fprintf('X');
				continue;
			end;
			if(mod(p,100)==0) fprintf('*');end;
			for fx=1:nfilt
                for fy=1:nfilt
				    dist   =(fx-mfx)^2+(fy-mfy)^2;
				    distval=exp(-dist/(2*dsigma*dsigma));
				    filt{fy,fx}=filt{fy,fx}+lrate*distval*(mxcrop-filt{fy,fx});
                end;%fy
			end;%fx
		end;%dataset
		fprintf('\n');
		%--------------------
	    %update learning rate and sigma
		dsigma = exp(log(dsigma)-dstep);
		lrate  = exp(log(lrate)-lstep);		
		for fy=1:nfilt
            for fx=1:nfilt
			    subplot(nfilt,nfilt,(fy-1)*nfilt+fx);imagesc(vec2Color((filt{fy,fx})));
            end;
		end;
		drawnow;
	end;%iter
	model.filters = filt;
	model.dsz     = dsz;
%end function


