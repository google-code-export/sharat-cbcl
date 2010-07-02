%-----------------------------------------------------------------------
%callback_scan_c1
%  Detects rigid objects. 
%parameters:
% img - [IN] input image (grayscale) or a C1 pyramid
% filt- [IN] a C1 pyramid containing the template of the object at one or more scales 
%            learning the template at multiple scales provides better accuracy
% callback_fcn - [IN] callback function to compute the C1 pyramid.
%                     The callback function should be of the form fun(img,SCALES)
% nScales      - [IN(optional)] specifies the number scales for which the S1 pyramid is constructed
% min_val      - [IN(optional)] specifies the minimum value in the confidence map that is treated
%                     as a detection
% msk          - [IN(optional)] an optional mask to modulate the confidence map
% ftr          - [OUT] cell array containing the results.
% ftr_names    - [OUT] cell array contaning names of outputs
%              - 'res'-result, a cell array containing M pyramids (one for each object)
%                DL   -detection list generated from the pyramid using inhibition of return
%                c1   -raw C1 pyramid output
% ver            version (can be used to track features)
%sharat@mit.edu
%-----------------------------------------------------------------------
function [ftr,ftr_name,ver] = callback_scan_c1(img,filt,callback_fcn,nScales,min_val,msk)
  global DEBUG;
  warning('off','all');
  if(nargin<4)
    nScales=12;
  end;  
  if(nargin<5)
    min_val  = 0.02;
  end;
  if(nargin<6)
    msk      = [];
  else
    msk      = im2double(msk);
  end;
  %------------------------------------------
  %preprocess
  %------------------------------------------
  if(iscell(img))%you can pass c1 as input as well
	c1       = img;
  else
    load patches_gabor;
  	ftr      = feval(callback_fcn,img,patches_gabor,nScales);
  	c1       = ftr{2}; clear ftr; 
  end;
  RES      = cell(length(filt),1);
  %-----------------------------------------
  %compute maps
  %-----------------------------------------
  num      = 1;
  for obj=1:length(filt)
	RES{obj}=cell(length(c1)-length(filt)+1,1);
    %--------------------------------------------------
    %filter the C1 map (filter_c1) is defined below
    %--------------------------------------------------
  	for s = 1:length(c1)-length(filt)+1
    	 RES{obj}{s}=filter_c1(c1{s},filt{obj}{1}); 
    	 for t=2:length(filt)
             RES{obj}{s}=RES{obj}{s}+imresize(filter_c1(c1{s+t-1},filt{obj}{t}),size(RES{obj}{s}))
    	 end;%t
	 if(~isempty(msk))
	   tmsk = imresize(msk,size(RES{obj}{s}),'bicubic');
	   if(DEBUG)
	     subplot(1,2,1);imagesc(RES{obj}{s});
	     subplot(1,2,2);imagesc(RES{obj}{s}.*tmsk);
	   end;%if
	   RES{obj}{s}=RES{obj}{s}.*tmsk;
	 end;%if
     if(isfield(filt{obj}{1},{'A','B'}))
	   RES{obj}{s}=1./(1+exp(filt{obj}{1}.A*RES{obj}{s}+filt{obj}{1}.B));
	 else
	   RES{obj}{s}=max(-inf,RES{obj}{s});%/length(filt{obj});%increase detection rate
	 end;
	 RES{obj}{s}=RES{obj}{s}-filt{obj}{1}.b;
	end;%s
  end;%obj

  %generate a list of detections after performing surround inhibition
  DL       =[];%detect_objects(img,filt,RES,min_val); 
  ftr      ={RES,DL,c1};
  ftr_name ={'res','DL','c1'};
  ver      =5;
%end function

%-----------------------------------------------------------------------
%
%-----------------------------------------------------------------------
function res = filter_c1(c1,filt)
      [ht,wt,d] = size(c1);
      res       = zeros(ht,wt);
      for i = 1:d
    	[fht,fwt]=size(filt.f(:,:,i));
         h      = filt.f(:,:,i)./(filt.sf(:,:,i)+eps);
         b      = sum(sum(filt.mf(:,:,i).*h));
	     tmp    = conv2(c1(:,:,i),h(end:-1:1,end:-1:1),'same')-b;
   	    res    = res+ tmp(1:ht,1:wt);
      end;
      res = res+filt.b;
%end function

%-----------------------------------------------------------------------
%
%-----------------------------------------------------------------------
function DL=detect_objects(img,filt,res,min_val)
   %locate the maximum
   global DEBUG;
   num     = 1;
   if(nargin<5)
   	min_val = 0.05;
   end;
   DL      = [];
   %---------------------------
   %determine masking radius
   %---------------------------	
   SIGMA   = [0,0];
   for m = 1:length(filt)
   	SIGMA(1) = max(SIGMA(1),size(filt{m}{1}.f,2));
	SIGMA(2) = max(SIGMA(2),size(filt{m}{1}.f,1));
   end;
   SIGMA   = SIGMA/2;
   while(num<50) %max objects
     %---------------------------
     %find maximum
     %---------------------------
     ret_val   =-inf;
     ret_pos   =[0,0];
     ret_scale =0;
     for m   = 1:length(res)
       for s   = 1:length(res{m})
		map       = res{m}{s};
		if(isempty(map))continue;end;
		[y,x]     = find(map==max(max(map)),1);
		if(map(y,x)>ret_val)
		ret_val   = map(y,x);
		ret_pos   = [y/size(res{m}{s},1),x/size(res{m}{s},2)];%relative position
		ret_scale = s;
		ret_obj   = m;
		end;
	end;
     end;
     if(ret_val<min_val)
       return;
     end;
     ret_pos          = ret_pos(2:-1:1);  %xy switcheroo
     DL(num).obj      = ret_obj;
     DL(num).pos      = ret_pos;
     DL(num).val      = ret_val;
     DL(num).s        = ret_scale; %relative scale
     fprintf('Maxima found at scale:%f\n',ret_scale);
     if(DEBUG)
       for m=1:length(res)
	 for s=1:length(res{m})
	     figure(97);
	     subplot(4,ceil(length(res{m})/4),s);
	     imagesc(res{m}{s});
	 end;
	 pause;
       end;
     end;
     %---------------------------------
     %supression
     %---------------------------------
     for m       = 1:length(res)
       for s       = 1:length(res{m})
	    [ht,wt]   = size(res{m}{s});
	    [cpos]    = ret_pos.*[wt,ht];        %center
	    [X,Y]     = meshgrid(1:wt,1:ht);      
	    sigma     = SIGMA;
	    gmap      = exp(-(X-cpos(1)).^2/(2*sigma(1)^2)-(Y-cpos(2)).^2/(2*sigma(2)^2));
	    decay     = exp(-(s-ret_scale)^2/(2*8^2));
	    res{m}{s} = res{m}{s}.*(1-decay*gmap);
       end;
     end;
     num = num+1;
   end;
   [t,idx] = sort([DL.val],'descend');
   DL      = DL(idx);
%end function

