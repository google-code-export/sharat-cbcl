%-------------------------------------------------------
%
%tx,ty-true x,true y
%bx,by-bounded x,y
%
%sharat@mit.edu
function [tx,ty,bx,by,shape]=sample_contour(img)
    global gDEBUG;
    img            = preprocess(img);
    [out,shape,fg] = cleanup(img);
    if(gDEBUG)
      subplot(1,2,1);imagesc(img);colormap('gray');axis image;
      subplot(1,2,2);imagesc(fg);colormap('gray');axis image;
      pause;
    end;
    boundaries     = bwboundaries(fg);
    for b=1:length(boundaries)
        len(b)=length(boundaries{b}(:,1));
    end;
    [val,idx]=sort(len,'descend');
    bnd=boundaries{idx(1)};
    x  =bnd(:,2);y  =bnd(:,1);
    xc =mean(x); yc =mean(y);
    %--------------------------------
    %absolute
    [th,r]=cart2pol(x-xc,y-yc);
    [val,idx]=sort(th);
    r     =r(idx);th    =th(idx);
    r     =imresize(r,[100 1],'bilinear');
    th    =imresize(th,[100 1],'bilinear');
    [x,y] =pol2cart(th,r);
    tx    =x+xc;ty=y+yc;
    %---------------------------------
    %bounded
    rmax  =max(r);
    r     =r/rmax;
    [bx,by]=pol2cart(th,r);
    %

