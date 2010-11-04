function RES = get_roc_ZER(pos,neg)

% Thresh       = sort([-neg; -pos]);
% Thresh       = sort(-neg);
% Thresh       = -Thresh;
% Thresh       = [Thresh(1)+0.01; Thresh; Thresh(end)-0.01]';
Thresh       = -linspace(-2,2,4000);
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

RES.roc      = trapz(FP, TP);

[v,I]        = min(abs((1-TP)-FP));
RES.errSame  = 1-(fp(I)+(length(pos)-tp(I)))/(length(pos)+length(neg));
RES.errZER   = TP(1);

RES.err      = (sum(pos<0)+sum(neg>=0))/(length(pos)+length(neg));
RES.Thresh   = Thresh;
