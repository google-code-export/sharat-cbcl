%----------------------------------------------------
%
%sharat@mit.edu
%----------------------------------------------------
function h_visualize_model(model)
 max_depth = length(model);
 for f=1:length(model{1}.filters)
     pout{f}=model{1}.filters{f};
 end;
 for i=1:max_depth
   nfilt=length(model{i}.filters);
   out  =cell(nfilt,1);
   figure(i);
   if(i>1)
      pnfilt=length(model{i-1}.filters);
      for f=1:pnfilt
	out{f}=pout{f};
      end;
   end;
   for f=1:nfilt
     if(i>1)
       pnfilt=length(model{i-1}.filters);
       psz   =size(model{i-1}.filters{1},1)
       sz    =size(model{i}.filters{1},1)
       idx   =model{i}.filters{f};
       idx   =ceil(idx*pnfilt+pnfilt/2)
       tout  =zeros(sz.*psz);
       for x=1:sz
	 for y=1:sz
	   tout((y-1)*psz+1:y*psz,(x-1)*psz+1:x*psz)=out{idx(y,x)};
	 end;%y
       end;%x
       pout{f}=tout;
     end;%i
     subplot(4,ceil(nfilt/4),f);imagesc(pout{f});axis image;colormap('gray');
   end;%f
   pause(1);
 end;%i
%end function
