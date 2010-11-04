function [X,Y,img_set]=aggregate_ftr(home,split,trainp)
	if(trainp)
		REGEX=sprintf('trn_%03d_*.mat',split);
	else
		REGEX=sprintf('tst_%03d_*.mat',split);
	end;
	d	= dir(fullfile(home,REGEX));
	d   = d(randperm(length(d)));
	%d   = d(1:10);
	%get feature length
	load(fullfile(home,d(1).name),'ftr');
	vec  = select_all(ftr);
	X    = zeros(length(d),length(vec));
	Y    = zeros(length(d),1);
	img_set=cell(length(d),1);
	for i=1:length(d)
	  fprintf('reading %d of %d-->%s\n',i,length(d),d(i).name);
	  try
		load(fullfile(home,d(i).name),'ftr','lbl','img_file');
 	    vec = select_all(ftr);
		fprintf('reading:%s\n',img_file);
		X(i,:)=vec(:)';
		Y(i)=lbl;
		img_set{i}=img_file;
	  catch
		err=lasterror;
		fprintf('error loading file\n');
		keyboard;
		continue;
      end;
	end;
%end function

function vec = select_all(ftr)
   load c2randidx;
   c2b=ftr{3}(:);
   c1=c12vec(ftr{1});
   c2=c12vec(ftr{2});c2=c2(c2randidx);
   vec=[c2b(:);c1(:);c2(:)];
function pix = select_pixel(ftr)
 pix = ftr{1}(:);
%end function;

function c1=select_c1(ftr)
        c1=ftr{1}{1}(:);

	
function res=select_c1_c2(ftr)
    %--------------------
	%resize
    ftr{2}{1}  = imresize(ftr{2}{1},[5 5]);
	%-------------------
	c2b=ftr{3};
	c2=c12vec(ftr{2});
	c1=c12vec(ftr{1});
	load ~/animals/cheadidx cidx;
	res=[c2b(:);c1(:);c2(cidx)];
	%res=[c2(:);c1(:)];
%end function

function mask = position_mask(retx,rety,retsz)
  [x,y]= meshgrid(-0.5:0.05:0.5,-0.5:0.05:0.5);
  mask = abs(x-retx)<=retsz & abs(y-rety)<=retsz;
%end function

function c2b=select_center_c2(ftr)
	c1=ftr{1};
	c2=ftr{2};
	c2b=ftr{3};
	if(length(ftr)>3)
		c2b=zeros(size(c2{1},3),1);
		for b=ftr{4}
			for i=1:length(c2b)
			  tmp    = c2{b}(:,:,i);;
			  c2b(i) = max([c2b(i);tmp(:)]);
			end;
		end;
	else
		return;
	end;
%end function

function c2b=select_c2(ftr)
	c1=ftr{1};
	c2=ftr{2};
	c2b=ftr{3};
	return;
	c2rand=c_generic(c2,3,2,length(c2));
	c2rand=imresize(c2rand{1},[2 2],'bicubic');
	if(length(ftr)>3)
		c2b=zeros(length(c2b),1);
		for b=max(1,ftr{4}-1):min(length(c2),ftr{4}+1)
			for i=1:length(c2b)
				tmp=c2{b}(:,:,i);
				c2b(i)=max([c2b(i);tmp(:)]);
			end;
		end;
		c2b = cat(1,c2b,c12vec(c1));
		c2b = cat(1,c2b,c2rand(:));
		c2b = cat(1,c2b,ftr{3});
		fprintf('length c2:%d\n',length(c2b));
	else
		return;
	end;
%end function

function h=select_c1_hist(ftr)
    h  = [];
	TH = 0.1;
	c1 = ftr{1};
	for b=1:length(c1)
		[tmp,idx]   = max(c1{b},[],3);
		idx(tmp<TH) = [];
		[n,x]       = hist(idx(:),0:size(c1{b},3));
		h           = [h,n/sum(n)];
	end;
%end function	

function h = select_c1_local_hist(ftr)
   TH = 0.1;
   c1 = ftr{1};
   out1=local_hist(c1,TH,7);
   out2=local_hist(c1,TH,13);
   h   =[out1{1}(:);out2{1}(:)];
%end function

function h = select_c2_local_hist(ftr)
   TH = 0.25;
   c1 = ftr{2};
   out1=local_hist(c1,TH,7);
   out2=local_hist(c1,TH,13);
   h   =[out1{1}(:);out2{1}(:)];
%end function

function h=select_c2_hist(ftr)
    h  = [];
	TH = 0.25;
	c2 = ftr{2};
	for b=1:length(c2)
		[tmp,idx]   = max(c2{b},[],3);
		idx(tmp<TH) = [];
		[n,x]       = hist(idx(:),0:size(c2{b},3));
		h           = [h,min(0.05,n/sum(n))];
	end;
%end function	

