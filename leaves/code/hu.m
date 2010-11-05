function h=hu(x,y)
%
h(1)=nu(x,y,2,0)+nu(x,y,0,2);
h(2)=(nu(x,y,2,0)-nu(x,y,0,2))^2+(2*nu(x,y,1,1))^2;
h(3)=(nu(x,y,3,0)-3*nu(x,y,1,2))^2+(3*nu(x,y,2,1)-nu(x,y,0,3))^2;
h(4)=(nu(x,y,3,0)+nu(x,y,1,2))^2+(nu(x,y,2,1)+nu(x,y,0,3))^2;

function m=mu(x,y,p,q)
  xbar=mean(x);
  ybar=mean(y);
  m=sum((x-xbar).^p.*(y-ybar).^q);
 
function res=nu(x,y,p,q)
  res=mu(x,y,p,q)/mu(x,y,0,0).^(1+(p+q)/2);

