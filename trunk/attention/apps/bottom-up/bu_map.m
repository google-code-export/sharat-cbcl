function out=bu_map(ftr,model,dims)
    if(nargin<3)
        dims=1:size(ftr{1},3);
    end;
    out=cell(length(ftr),1);
    for b=1:length(ftr)
        [ht,wt,depth]=size(ftr{b});
        map=zeros(size(ftr{b},1),size(ftr{b},2));
        for p=1:length(dims)
            p0 =model.qtl(dims(p));
            map=map+log((ftr{b}(:,:,dims(p))>=model.thresh(dims(p)))*(1-p0)+...
                        (ftr{b}(:,:,dims(p))<model.thresh(dims(p)))*p0);
        end;
        %weak central bias
        [x,y] =meshgrid(1:wt,1:ht);
        sigma =min([ht,wt]/3);%arbitrary
        msk   =exp(-((x-wt/2).^2+(y-ht/2).^2)/(2*sigma*sigma));
        out{b}=imfilter(-map,fspecial('gaussian'));
    end;
%end function
