%-------------------------------------------------------
%
%sharat@mit.edu
function ftr=callback_c1_leaves(img,patches)
    if(~isnumeric(img))
        img = imread(img);
    end;
    c0  = create_c0(img,sqrt(2),8);
    s1  = s_norm_filter(c0,patches);
    c1  = c_local(s1,11,5,2,2);
    ftr = {s1,c1};
%

