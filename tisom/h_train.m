function model=h_train(img_set,dsz,nfilts,MAXITER)
  if(nargin<4)
    MAXITER=75;
  end;
  if(length(dsz)~=length(nfilts))
    error('unequal domain and filter sizes');
  end;
  
  model    =cell(1,length(dsz))
  for level=1:length(dsz)
    model{level}=train_dictionary(img_set,dsz(level),...
	         ceil(dsz(level)/2),nfilts(level),MAXITER);
    %-----------------------------
    %prepare next level input
    for i=1:length(img_set)
      img_set{i}=quantize_domain(img_set{i},model{level});
    end;
  end;
%end function
