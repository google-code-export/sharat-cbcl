%-------------------------------------------------------
%
%sharat@mit.edu
function ftr=callback_c2_leaves(img,c0Patches,c1Patches,sigma)
    ftr = callback_c1_leaves(img,c0Patches);
    c1  = ftr{2};clear ftr;
    c2b = [];
    c1b = [];
    for b=1:length(c1)
        s2  = s_grbf(c1(b),c1Patches{b},sigma(b));
        sz  = size(c1Patches{b}{1},1)
        c2  = c_resize(s2,4,3);
        c2b = cat(1,c2b,c2{1}(:));
        chist=c_hist(c1(b),4,3);
        c1b = cat(1,c1b,chist{1}(:));
    end;
    ftr={c2b(:),c2,[c1b(:);c2b(:)]};
%

