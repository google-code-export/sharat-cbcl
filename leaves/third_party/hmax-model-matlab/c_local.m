%------------------------------------------------------------
%c_local
% performs local pooling across locations and scales
% parameters:
%            s : [IN] input scale pyramid
%          POOL: [IN] spatial pooling 
%          STEP: [IN] step size while pooling
%          SCALEPOOL: [IN] number of scales to pool over
%          SCALESTEP: [IN} step size in scales
%          out : [OUT] output scale pyramid. 
%sharat@mit.edu
%-------------------------------------------------------------
function out  = c_local(s,POOL,STEP,SCALEPOOL,SCALESTEP)
  if(nargin<2)
	POOL        = 9;
  end;
  if(nargin<3)
	STEP        = 5;
  end;
  if(nargin<4)
	SCALEPOOL   = 2;
  end;
  if(nargin<5)
    SCALESTEP   = SCALEPOOL;
  end;
  BANDS       = length(1:SCALESTEP:length(s)-SCALEPOOL+1)
  %---------------------------
  %max in bands
  %--------------------------
  b         = 1;
  for start = 1:SCALESTEP:length(s)-SCALEPOOL+1
    [ht,wt,d]     = size(s{start});
    out{b}        = zeros(ht,wt,d);
    for off  = 0:SCALEPOOL-1
      stmp   = imresize(single(s{start+off}),[ht wt]);
      out{b} = max(out{b},imdilate(single(stmp),ones(POOL),'same'));
    end;	
    b             = b+1;
  end;
  for b = 1:BANDS
    out{b}= out{b}(max(1,floor(POOL/2)+1):STEP:min(end-ceil(POOL/2)+1,size(out{b},1)),...
                   max(1,floor(POOL/2)+1):STEP:min(end-ceil(POOL/2)+1,size(out{b},2)),...
                   1:size(out{b},3));
  end;
%end function

