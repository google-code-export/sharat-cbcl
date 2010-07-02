function out=imscale(img)
mn=min(img(:));
mx=max(img(:));
out=min(1,max(0,(img-mn)/(mx-mn)));

