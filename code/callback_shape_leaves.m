%-------------------------------------------------------
%
%sharat@mit.edu
function ftr=callback_shape_leaves(img)
     img         = preprocess(img);
     img         = rescaleHeight(img,600);
     [tx,ty,bx,by,shape]=sample_contour(img);
    ftr   =[tx(:);ty(:);bx(:);by(:);shape(:)];
%

