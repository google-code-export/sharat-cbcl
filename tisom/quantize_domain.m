%----------------------------------------------------------------------------
%
%sharat@mit.edu
%----------------------------------------------------------------------------
function [res,dout,sx,sy] = quantize_domain(img,model,CALLBACK)
    if(nargin<3)
	  CALLBACK='convdist';
    end;
	res      = zeros(size(img));
	[ht,wt,d]= size(img);
	dsz      = model.dsz;
	nfilt    = length(model.filters(:));
	filtsz   = size(model.filters{1},1);
	shift    = ceil(dsz/2);
	qout     =  []; sx=[]; sy=[];dout=[];
	xidx =1;
    %------------------------
	%determine norm
    for f=1:length(model.filters(:))
	  pnorm(f)=norm(model.filters{f}(:));
    end;
	[val,idx]=sort(pnorm,'descend');
    model.filters=model.filters(idx);
    model.filters{end}=zeros(size(model.filters{end}));
    %-------------------------
    %determine tuning function
    cnt  =0; dist=0;
    for i=1:length(model.filters(:))
      for j=i+1:length(model.filters(:))
		dist=dist+norm(model.filters{i}(:)-model.filters{j}(:))^2;
        cnt =cnt+1;
      end;
   end;
   SIGMA=sqrt(mean(dist/cnt));
	for x=1:shift:wt-dsz+1
		yidx = 1;
		for y=1:shift:ht-dsz+1
			crop=img(y:y+dsz-1,x:x+dsz-1,:);
			maxval=-inf;maxidx=-1;
			val   = zeros(nfilt,1);
			for f=1:length(model.filters(:))	
				out    =feval(CALLBACK,crop,model.filters{f},SIGMA);
				maxout =max(out(:));
				val(f) =maxout;
				if(maxout>maxval)
					[mxi,mxj]=find(out==maxout,1);
					maxval	 =maxout;
					maxidx	 =f;
				end;	
		  end;%f	
		  dout(yidx,xidx,maxidx)=1;
		  %---------------------------
		  %assign output
		  sx(yidx,xidx)  =mxj;mxj=mxj+floor(filtsz/2);
		  sy(yidx,xidx)  =mxi;mxi=mxi+floor(filtsz/2);
		  blk            =zeros(filtsz,filtsz,d);
		  res(y+mxi:y+mxi+filtsz-1,x+mxj:x+mxj+filtsz-1,:)=model.filters{maxidx};
		  yidx=yidx+1;
		end;%y
		xidx = xidx+1;
	end;%x
	res = res(1:ht,1:wt);  
    dout= dout(:,:,1:end-1);
%end function
