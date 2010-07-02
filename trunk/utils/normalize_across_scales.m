%-------------------------------------------------
%
%sharat@mit.edu
%------------------------------------------------
function map=normalize_across_scales(map)
  sum_map=0;
  for i=1:length(map)
    sum_map = sum_map+sum(map{i}(:));
  end;
  for i=1:length(map)
    map{i}=map{i}/sum_map;
  end;
%end function
