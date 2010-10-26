%function dummy_function
%sharat@mit.edu
%The function ignore the image and returns a noisy
%version of the class variables. This function is 
%used soley to test the framework
function ftr=dummy_function(img,family,order)
  ftr=[family;order]
  ftr=ftr+0.1*randn(size(ftr));

