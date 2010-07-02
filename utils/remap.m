%--------------------------------------------
%
%sharat@mit.edu
%--------------------------------------------
function Y = remap(Y,groups,vals)
  orgY  =Y;
  for m = 1:length(groups)
    for n = 1:length(groups{m})
      Y(orgY==groups{m}(n)) = vals(m);
    end;
  end;
%end function
