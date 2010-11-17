function [out,shape,fg]=cleanup(input)
   global gDEBUG
   if(~isfloat(input))
       input=im2double(input);
   end;    
   img    =rescaleHeight(input,500);
   htScale=size(input,1)/size(img,1);
   wtScale=size(input,2)/size(img,2);
   %------------------------
   %compute foreground
   img  =imerode(img,ones(3,3));
   img  =imerode(img,ones(3,3));
   img  =imerode(img,ones(3,3));
   %sometimes emgmm fails
   success=0;
   for trials=1:10
        try
            model=emgmm(double(img(:)'),struct('ncomp',4,'init','random','cov_type','spherical'));
            success=1;
        catch
            fprintf('EMGMM Failed:Trying again..(%d/10)\n',trials)
            success=0;
            continue;
        end;
        if(success)break;end;
   end;
   if(~success)
       disp('EMGMM failed 10 times');
       throw(MException('Internal','EMGMM Failed'));
   end;    
   %background is assumed to be the brightest component
   [mn,max_idx]=max(model.Mean(:));     
   fg=reshape(1-model.Alpha(max_idx,:),size(img));
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
