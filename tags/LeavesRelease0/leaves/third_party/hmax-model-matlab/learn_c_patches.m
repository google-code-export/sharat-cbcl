%---------------------------------------------------------
%get_random_patches
%Given a set of training images, the function returns a set of 
%N training patches. 
%These patches are used as prototype features in computing 
%the S2b and C2b layers in the model. 
%sharat@mit.edu
%---------------------------------------------------------
function patches = learn_c_patches(img_set,CALLBACK,patches_gabor,N)
DEBUG      = 0;
DOMIN      = 0;
TRIALS     = 25;
%-------------------------------------------
%establish funciton to call
%-------------------------------------------
if(isempty(CALLBACK))
  CALLBACK  = 'callback_c1_baseline';
end;
num_images      = length(img_set);
psz             = 4;

%--------------------------------------------
%initialize patches
%
for i = 1:N
	for j=1:(1+10*rand)
	  patches{i}	= rand(psz,psz,4);
	end;
end;
DSIGMA     = N/2;
NU         = 0.05;

%-------------------------------------------
%get filters
%--------------------------------------------
try
for t=1:TRIALS
  img_set=img_set(randperm(length(img_set)));
  for i = 1:min(100,num_images)
	fprintf('Trial:%d,Processing %d of %d\n',t,i,num_images);
	img       = img_set{i};
	if(~isnumeric(img))
	  img     = im2double(rgb2gray(imread(img_set{i})));
	end;
	%----------------------------
	%extract s1 and c1
	%----------------------------
	[iht,iwt,tt]=size(img);
	ftr      = feval(CALLBACK,img,patches_gabor,2);
	c1       = ftr{2}(1);
	[cht,cwt,cd]=size(c1{1});
	if(cht<=psz|cwt<=psz) continue;end;
	if(DEBUG)
	  imagesc(img);axis image;
	end;
	s        = s_grbf(c1,patches,1);
	c        = c_global(s);
	maxval   = max(c(:));
	pnum = find(c==maxval,1) 
	[i,j]        = find(s{1}(:,:,pnum)==maxval);
	i            = max(i-floor(psz/2),1);
	j            = max(j-floor(psz/2),1);
	xrange       = j:min(j+psz-1,cwt);
	yrange       = i:min(i+psz-1,cht);
	crop         = c1{1}(yrange,xrange,:);
	if(size(crop,1)~=psz | size(crop,2)~=psz)
	  fprintf('*');
	  continue;
	end;
	for q=1:N
	  dist         = abs(q-pnum);
	  distval      = exp(-(dist*dist)/(2*DSIGMA*DSIGMA));
 	  patches{q}   = patches{q}+NU*distval*(crop-patches{q});
	end;
  end;%i
  visualize_patches(patches,0);
  %------------------
  %update learning param
  NU     = exp(log(NU)-0.05);
  DSIGMA = exp(log(DSIGMA)-0.05);
end;
catch
  err=lasterror;
  keyboard;
end;
