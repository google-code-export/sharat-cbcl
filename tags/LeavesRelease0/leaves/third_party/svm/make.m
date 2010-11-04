% This make.m is used under Windows

mex -largeArrayDims -cxx -O -c svm.cpp
mex -largeArrayDims -cxx -O -c svm_model_matlab.cpp
mex -largeArrayDims -cxx -O svmtrain.cpp svm.o svm_model_matlab.o
mex -largeArrayDims -cxx -O svmpredict.cpp svm.o svm_model_matlab.o
mex -largeArrayDims -cxx -O read_sparse.cpp
