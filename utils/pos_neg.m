function [pos,neg] = pos_neg(ss)
   pos = (ss>0);
   neg = (ss<=0);
   pos = ss.*pos;
   neg = -ss.*neg;
%end function
