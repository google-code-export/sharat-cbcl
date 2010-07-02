%--------------------------------------------------
%
%sharat@mit.edu
%-----------------------
function rec = h_reconstruct(res,model)
  nlevel = length(res);
  rec{nlevel}   = res{nlevel};
  rec{nlevel}.fb= res{nlevel}.rec;
  res{nlevel}.fb= res{nlevel}.rec;
  for i=nlevel-1:-1:1
    shift  = ceil(model{i}.dsz/2);
    out    = zeros(size(res{i}.rec));
    nfilt  = length(model{i}.filters);
    filtsz = size(model{i}.filters{1},1);
    
    [ht,wt]= size(out);
    xidx =1;
    for x=1:shift:wt-model{i}.dsz+1
      yidx =1;
      for y=1:shift:ht-model{i}.dsz+1
	f  = (res{i+1}.out(yidx,xidx)*nfilt+nfilt/2)
	sx = res{i}.sx(yidx,xidx);
	sy = res{i}.sy(yidx,xidx);
	out(y+sy:y+sy+shift-1,x+sx:x+sx+shift-1)=model{i}.filters{f};
	yidx=yidx+1;
      end;
      xidx = xidx+1;
    end;
    rec{i}     = res{i};
    rec{i}.fb  = out(1:ht,1:wt); 
    res{i}.fb  = rec{i}.fb;
  end;
%end function
