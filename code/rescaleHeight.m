%--------------------------------------------------------
%
%sharat@mit.edu
function out=rescaleHeight(img,newHt)
    [ht,wt,d]=size(img);
    newWt    =ceil(newHt/ht*wt);
    out      =imresize(img,[newHt newWt],'bicubic');
    
