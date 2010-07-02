%----------------------------------------------------------------------------
%
%sharat@mit.edu
%----------------------------------------------------------------------------
function [qout,res,sx,sy] = quantize_domain_dist(img,model)
	if(isrgb(img)) 
		img = rgb2gray(img);
	      end;
	if(~isfloat(img))
		img = im2double(img);
	end;
	res    = zeros(size(img));
	[ht,wt]= size(img);
	dsz    = model.dsz;
	nfilt  = length(model.filters);
	filtsz = size(model.filters{1},1);
	shift  = ceil(dsz/2);
	qout   =  []; sx=[]; sy=[];
	xidx =1;
	for x=1:shift:wt-dsz+1
		yidx = 1;
		for y=1:shift:ht-dsz+1
			crop=imcrop(img,[x,y,dsz-1,dsz-1]);
			maxval=inf;maxidx=-1;
			val = zeros(length(model.filters),1);
			for f=1:length(model.filters)	
			    dist    = conv2(ones(filtsz,1),ones(filtsz,1),crop.^2,'valid');
				dist    = dist+sum(model.filters{f}(:).^2);
				dist    = dist-2*conv2(crop,model.filters{f}(end:-1:1,end:-1:1),'valid');
				out     = dist;
				maxout  = min(out(:));
				val(f)  = maxout;
				if(maxout<maxval)
					[mxi,mxj]=find(out==maxout,1);
					maxval	 =maxout;
					maxidx	 =f;
				end;	
			end;%f
			fprintf('%f ',val);
			fprintf('\n');
			%---------------------------
			%assign output
			qout(yidx,xidx)=maxidx;%(maxidx-nfilt/2)/(nfilt);
			sx(yidx,xidx)  =mxj;mxj=mxj+floor(filtsz/2);
			sy(yidx,xidx)  =mxi;mxi=mxi+floor(filtsz/2);
      		res(y+mxi:y+mxi+filtsz-1,x+mxj:x+mxj+filtsz-1)=model.filters{maxidx};
			yidx=yidx+1;
		end;%y
		xidx = xidx+1;
	end;%x
	res = res(1:ht,1:wt);  
%end function
