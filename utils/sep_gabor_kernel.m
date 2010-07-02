function [gx,gy] = sep_gabor_kernel(sz,theta)
    x = -floor(sz/2):floor(sz/2);
    y = -floor(sz/2):floor(sz/2);
    s =  sz/6;
    l =  sz/3;
   gx =  exp(-x.^2/(2*s*s)).*exp(i*2*pi*x/l*cos(theta));
   gy =  exp(-y.^2/(2*s*s)).*exp(i*2*pi*y/l*sin(theta));
%end function