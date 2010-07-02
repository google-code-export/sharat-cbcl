function [salMap,imgOut] = POST_modulateImage(imgIn, salMap, color,perct)
if(nargin<3)
    color=[0.3 1 0.3];
end;
if(nargin<4)
    perct=0.2;
end;

salMap = imfilter(salMap,fspecial('gaussian'));
den    = imfilter(ones(size(salMap)),fspecial('gaussian'))+eps;
salMap = salMap./den;

salMap = imresize(salMap,ceil([size(imgIn,1),size(imgIn,2)]*0.25),'bicubic');
salMap = imresize(salMap,ceil([size(imgIn,1),size(imgIn,2)]*0.5),'bicubic');
salMap = imresize(salMap,[size(imgIn,1),size(imgIn,2)],'bicubic');
maxVal = max(max(salMap));
minVal = min(min(salMap));
salMap    = (salMap - minVal) ./ (maxVal - minVal); 
[mix,idx] = sort(salMap(:),'descend');
salMap    = zeros(size(salMap));

idxt =idx(1:floor(perct*length(idx)));
idx05=idx(1:floor(0.05*length(idx)));
idx10=idx(1:floor(0.1*length(idx)));
idx20=idx(1:floor(0.2*length(idx)));

salMap(idxt)=0.25;
if(perct>=.20)
salMap(idx20)=0.5;
end;
if(perct>=.10)
salMap(idx10)=0.75;
end;
if(perct>=.05)
salMap(idx05)=0.9;
end;

if(nargin<3 | isscalar(color))
  imgOut  = BlueMask(salMap,imgIn,0.75,[0.3 1 0.3]);
else
  imgOut  = BlueMask(salMap,imgIn,0.75,color);
end;
imgOut    = min(imgOut,1);
imgOut    = max(imgOut,0);
%end
