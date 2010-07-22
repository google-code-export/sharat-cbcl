function x=sigmoid(x,a,b)
if(nargin<3)
    b=0;
end;
if(nargin<2)
    a=-1;
end;    
x=1./(1+exp(a*x+b));
