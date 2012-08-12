%-----------------------------------------------------------------
%
%sharat@mit.edu
%high pass filter on the image.
function out=preprocess(img)
	 sigma = 3;
	 img = im2double(img);
   filt=fspecial('gaussian', 3 * sigma, sigma);
	 hsz = (size(filt, 1)-1)/2;
	 out = conv2(img, filt, 'valid');
   out = img(hsz + 1:end - hsz, hsz + 1:end- hsz) - out;
%end function
