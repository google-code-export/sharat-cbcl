function x=call_phog(img,varargin)
    try
        img=rescaleHeight(im2double(img),800);
        p=anna_phog(img,8,360,3,[1,size(img,1),1,size(img,2)]');
    catch
        err=lasterror;
        p=zeros(1,2040);
        disp('PHOG Error!');
    end;
    x=p(:);
%end function
