function c=c_resize(s,cht,cwt)
    nbands=length(s);
    c     ={};
    for b=1:nbands
        [ht,wt,dims]=size(s{b});
        blkHt    =ceil(ht/cht);
        ypad     =ceil(ht/cht/4);
        blkWt    =ceil(wt/cwt);
        xpad     =ceil(wt/cwt/4);
        c{b}     =[];
        for d=1:dims
            c{b}(:,:,d)=blkproc(s{b}(:,:,d),[blkHt blkWt],[ypad xpad],inline('max(x(:))'));
        end;
    end;
%end function
