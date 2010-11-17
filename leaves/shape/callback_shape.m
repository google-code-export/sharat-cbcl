function ftr=callback_contour(img,varargin)
 [tx,ty,bx,by,shape]=sample_contour(img);
 ftr=[bx(:);by(:);shape(:)];
