function RES = get_roc(pos,neg)

if ~isempty(neg)
scores      = [neg(:);pos(:)];
Thresh      = sort(-(scores))';
Thresh      = -Thresh;

distf        = repmat(pos', length(Thresh), 1);
Thr          = repmat(Thresh', 1, length(pos));
tp           = sum(distf >= Thr, 2);
TP           = tp / length(pos);

distnf       = repmat(neg', length(Thresh), 1);
Thr          = repmat(Thresh', 1, length(neg));
fp           = sum(distnf >= Thr, 2);
FP           = fp / length(neg);
 
RES.FP       = FP;
RES.TP       = TP;

%approx roc area
RES.roc      =  auc3(FP,TP);
%RES.roc      =  trapz(FP,TP);
[v,I]        =  min(abs((1-TP)-FP)); 
I            =  I(1);
%equal error rate
RES.errSame  =  1-TP(I)+FP(I);
idx          =  find(FP==0); 
if(~isempty(idx))
  idx = idx(1);
  %error at zero FP
  RES.errZER   =  1-TP(idx);
else
  RES.errZER   = 1;
end;
%minimum total error
RES.err      =  min(1-TP+FP);

else
    RES.err  = sum(pos>0);
end

%------------------------------
%
%-----------------------------
function a = auc3(px,py,M);
px = px(:);
py = py(:);

if(isempty(px))
  a = .5;
  return;
end

if(nargin < 3), M = 1;, end

px = sort(px);
py = sort(py);
px = px(find(px < M));
py = py(1:length(px));

e = [px,py];
a = 0;
de = diff(e);
%% for i=1:(size(de,1))
%%  a = a + de(i,1)*(e(i+1,2) - de(i,2)/2);
%% end
for i = 2:length(px)
  h   = px(i)-px(i-1);
  a   = a+ 0.5*h*(py(i)+py(i-1));
  % a = a + (rectangle part) + (triangle part)
  % a = a + (de(i-1,1) * py(i-1)) + (0.5)*(de(i-1,1)*py(i));
  %a = a + de(i-1,1) * ( py(i-1) + (0.5)*(de(i-1,2)));
end
return
