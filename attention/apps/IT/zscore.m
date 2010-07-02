function s=zscore(s)
   for b=1:length(s)
       mn=mean(s{b}(:));
       sd=std(s{b}(:));
       [pos,neg]=pos_neg((s{b}-mn)/(sd+1e-4));
       s{b}=cat(3,pos,neg);
   end;
%
