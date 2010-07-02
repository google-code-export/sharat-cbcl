%-------------------------------------------------------------------------
%
%sharat@mit.edu
%-------------------------------------------------------------------------
function model = train_dictionary_som(img_set,dsz,nfilt,MAXITER)
	if(nargin<5)
		MAXITER = 10;
	end;
	%-----------------------------------
	%get all patches
	dset     = {};
	filtsz   = floor(dsz/2);
	for i=1:length(img_set)
		dset=cat(2,dset,imgset_to_dset_color(img_set{i},dsz));
	end;
	fprintf('Patches:%d\n',length(dset));
	idx  = randperm(length(dset));
	dset = dset(idx(1:min(length(dset),100)));		
	%-----------------------------------
	%initialize distances
	for i=1:length(dset)
	  off    =randperm(dsz-filtsz+1);
	  xoff(i)=off(1);
	  off    =randperm(dsz-filtsz+1);
	  yoff(i)=off(1);
	end;
    nDim     = size(dset{1},3);
 	for iter = 1:MAXITER
		fprintf('Iteration:%d\n',iter);
		X     =zeros(filtsz*filtsz*nDim,length(dset));
		for p=1:length(dset)
		  fprintf('Crop,%d,%d\n',xoff(p),yoff(p));
		  patch =imcrop(dset{p},[xoff(p),yoff(p),filtsz-1,filtsz-1]);
		  X(:,p)=patch(:);
		end;
		%----------------------------------
		%get som
		%
		mnmx = repmat([0 1],size(X,1),1);
		net  = newsom(mnmx,[nfilt nfilt],'gridtop');
		net.trainParam.epochs=50;
		net.trainParam.show  =1;
		net.trainParam.showCommandLine=1;
		net.trainParam.showWindow=0;
		T   = [];
		net = train(net,X);
		T  =sim(net,X);T=vec2ind(T);
		%---------------------------------
		%get filt
		for n=1:nfilt*nfilt
		  pFilt{n}=net.IW{1}(n,:);
		  pFilt{n}=reshape(pFilt{n},[filtsz filtsz nDim]);
		end;
		for p=1:length(dset)
		  maxres=0;
		  for n=1:nfilt*nfilt
		    res=convdist(dset{p},pFilt{n});
			xmax=1;ymax=1;
			if(max(res(:))>maxres)
			  maxres=max(res(:));
			  [ym,xm]=find(res==maxres,1);
			  xmax   =xm;
			  ymax   =ym;
			end;
		  end;%n
		  xoff(p)=max(1,min(xmax,dsz-filtsz+1));
		  yoff(p)=max(1,min(ymax,dsz-filtsz+1));
		end;
	end;%iter
for i=1:nfilt*nfilt;
[res,idx]=max(pFilt{i},[],3)
idx(idx==1)=1;
idx(idx==2)=-1;
idx(idx==3)=0;
subplot(nfilt,nfilt,i);imagesc(imfilter(idx,fspecial('laplacian'),'full'));axis image off;
end;
keyboard;
    
keyboard;
%end function


