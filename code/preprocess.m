%-----------------------------------------------------------------
%
%sharat@mit.edu
%
function out=preprocess(img)
   filt=fspecial('gaussian',35,5);
   filt=sum(filt);
   if(isrgb(img))
       img=im2double(rgb2gray(img));
   end;
   num =conv2(filt,filt,img);
   den =conv2(filt,filt,ones(size(img)));
   out =num./den;
   out =out-mean(out(:));
   out =out./(std(out(:))+1e-4);
%end function
