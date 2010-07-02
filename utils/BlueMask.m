function outIm = BlueMask(mask,inIm,alpha,color);
%function outIm = BlueMask(mask,inIm,alpha,color);
%
%operates like BlueBox, but uses a mask the same size as inIm instead of a rectangle
if(nargin < 4)
   color = [0 0 1];
end
if(nargin < 3)
   alpha = .5;
end
if(size(inIm,3) == 1)
   inIm = repmat(inIm,[1 1 3]);
end
if(isinteger(inIm))
   inIm = im2double(inIm);
end
mask = alpha * mask;
mask = repmat(mask,[1 1 3]);
tempIm = inIm;
for iColorLayer = 1:3
   tempIm(:,:,iColorLayer) = color(iColorLayer);
end
outIm = (1-mask) .* inIm + (mask) .* tempIm;


