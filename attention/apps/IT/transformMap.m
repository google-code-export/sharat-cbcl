function out=transformMap(c2,thresh)
  out =zeros(size(c2));
  nFtr=size(c2,3);
  for f=1:nFtr
	out(:,:,f)=(c2(:,:,f)>thresh(f));
  end;
%end function
