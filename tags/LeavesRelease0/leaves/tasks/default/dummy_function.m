%function dummy_function
%sharat@mit.edu
%The function ignore the image and returns a noisy
%version of the class variables. This function is 
%used soley to test the framework
function ftr=dummy_function(img,family,order)
  fvec=zeros(200,1);fvec(family)=1;
  ovec=zeros(200,1);ovec(order)=1;
  ftr=[fvec(:);ovec(:)];

