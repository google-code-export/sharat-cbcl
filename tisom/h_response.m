%----------------------------------------------
%
%sharat@mit.edu
function res = h_response(img,model,max_depth)
 if(nargin<3)
   max_depth = length(model);
 end;
 res      =cell(max_depth,1);
 for level=1:max_depth
   [out,rec,sx,sy]=quantize_domain(img,model{level});
   res{level}     =struct('ff',img,'out',out,'sx',sx,'sy',sy,'rec',rec);
   %next level
   img            =out;
 end;
%end function
