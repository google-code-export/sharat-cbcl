function c=c_hist(s,cht,cwt)
    nbands=length(s);
    c     ={};
    for b=1:nbands
        [ht,wt,dims]=size(s{b});
        ht=max(ht,6);
        wt=max(wt,6);
        s{b}=imresize(s{b},[ht wt],'bicubic');
        if(ht<cht | wt<cwt)
            s{b}=imresize(s{b},[cht cwt],'bicubic');
        end;    
        %for small
        blkHt    =ceil(ht/cht);
        blkWt    =ceil(wt/cwt);
        c{b}     =[];
        [val,idx]=max(s{b},[],3);
        for d=1:dims
            c{b}(:,:,d)=blkproc(idx==d,[blkHt blkWt],inline('mean(x(:))'));
        end;
    end;
%end function
