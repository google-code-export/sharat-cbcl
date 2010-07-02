%generates precision recall curve
function precision_recall_curve(tp,fp,num)
  scores = [tp,fp];
  thresh = linspace(min(scores),max(scores),100);
  N      = length(thresh);
  for i  = 1:N
    tmp_tp = sum(tp>=thresh(i));
    tmp_fp = sum(fp>=thresh(i));
    prec(i)= tmp_tp/num;
    rec(i) = tmp_tp/(tmp_tp+tmp_fp);
  end;
  plot(1-prec,rec);
%end function
