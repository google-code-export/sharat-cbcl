function gabors=getGabors(RF,N)
    [fsz,filters]=init_gabor(linspace(0,180-180/N,N),RF,4);
	gabors       =zeros(RF,RF,8);
	for i=1:N
	  gabors(:,:,i)=reshape(filters(:,i),[RF RF])';
	end;
