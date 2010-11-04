function [out,shape,fg]=cleanup(input)
   global gDEBUG
   img    =rescaleHeight(input,400);
   htScale=size(input,1)/size(img,1);
   wtScale=size(input,2)/size(img,2);
   %------------------------
   %compute foreground
   img  =imerode(img,ones(3,3));
   img  =imerode(img,ones(3,3));
   img  =imerode(img,ones(3,3));
   model=emgmm(img(:)',struct('ncomp',2,'init','random'));
   if(model.Mean(1)<model.Mean(2))
     fg=reshape(model.Alpha(1,:),size(img));
   else
     fg=reshape(model.Alpha(2,:),size(img));
   end;
   fg = imfill(im2bw(fg),'holes');
   fg = imerode(fg,ones(3,3));
   fg = imerode(fg,ones(3,3));
   fg = imerode(fg,ones(3,3));
   fg = imresize(fg,size(input));
   if(gDEBUG)
       subplot(1,2,1);imagesc(input);axis image off;
       subplot(1,2,2);imagesc(fg);axis image off;
   end;
   L  = regionprops(bwlabel(fg),{'BoundingBox','Area','FilledImage'});
   bbox=[];maxArea=0;shape=[];
   for l=1:length(L)
       if(L(l).Area>maxArea)
           bbox=L(l).BoundingBox;
           maxArea=L(l).Area;
           shape  =max(0,imresize(double(L(l).FilledImage),[8 8],'bicubic'));
       end;
   end;
   bbox=bbox+[-32 -32 64 64];
   out= imcrop(input,ceil(bbox));
%end function
