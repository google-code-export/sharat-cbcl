function gd = preProcess(img)
    if(isrgb(img))
	  img=rgb2gray(img);
	end;
	img      =im2double(img);
	img      =imfilter(img,fspecial('gaussian'));
	img      =imresize(img,0.25,'bicubic');
	img      =imfilter(img,fspecial('laplacian'));
	gd       =img;
	%[pos,neg]=pos_neg(img);
	%out                          =3*ones(size(img));
	%out(pos>quantile(pos(:),0.8))=1;
	%out(neg>quantile(neg(:),0.8))=2;
	%gd=zeros(size(img,1),size(img,2),3);
	%gd(:,:,1)=pos;
	%gd(:,:,2)=neg;
	%for i=1:3
	%  gd(:,:,i) = (out==i);
	%end;
