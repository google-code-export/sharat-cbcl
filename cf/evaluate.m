function [prec,recall]=evaluate(yhat,y,N)
y(y~=1)=0;
prec=0;
recall=0;
if(nargin==3)
  dosort=1
else
  dosort=0
end;

for t=1:size(yhat,1)
  if(dosort)
	val=sort(yhat(t,:),'descend');
	dec=yhat(t,:)>val(N+1);
  else
	dec=yhat(t,:);
  end;
  match=sum(y(t,:).*dec);
  recall=recall+match/sum(y(t,:));
  prec=prec+match/(sum(dec)+eps);
end;
recall=recall/size(yhat,1);
prec=prec/size(yhat,1);
%end function
