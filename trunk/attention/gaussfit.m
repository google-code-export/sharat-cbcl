function val=gaussfit(vec,xval,yval)
    mean=vec(1);
    sigma=vec(2);
    mag=vec(3);
    offset=0.3;%vec(4);
    y=offset+mag*exp(-(xval-mean).^2/(2*sigma*sigma));
    val=mse(y-yval);
%end function