[stat,res]=system('pkg-config opencv --libs --cflags');
res       =res(1:end-2); %remove \n
for file  ={'callback_c1_baseline.cpp','callback_s2_c2_baseline.cpp'}
 ofile=' image.cpp filter.cpp operations.cpp cbcl_model_internal.cpp ';
 eval(['mex -I../inc '  res ' ' char(file) ofile]);
end;
