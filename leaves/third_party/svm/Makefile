# This Makefile is used under Linux

MATLABDIR = /cbcl/local/matlab_r2006b
CXX = g++
#CXX = g++-3.3
CFLAGS = -Wall -O3 -fPIC -I$(MATLABDIR)/extern/include

MEX = $(MATLABDIR)/bin/mex
MEX_OPTION = CC\#$(CXX) CXX\#$(CXX) CFLAGS\#"$(CFLAGS)" CXXFLAGS\#"$(CFLAGS)"
# uncomment the following line if you use MATLAB 7.3 (or above) on 64-bit computer
#MEX_OPTION += -largeArrayDims
MEX_EXT = $(shell $(MATLABDIR)/bin/mexext)

all: svmpredict.$(MEX_EXT) svmtrain.$(MEX_EXT) read_sparse.$(MEX_EXT)

svmpredict.$(MEX_EXT):     svmpredict.cpp svm.h svm.o svm_model_matlab.o
	$(MEX) $(MEX_OPTION) svmpredict.cpp svm.o svm_model_matlab.o

svmtrain.$(MEX_EXT):       svmtrain.cpp svm.h svm.o svm_model_matlab.o
	$(MEX) $(MEX_OPTION) svmtrain.cpp svm.o svm_model_matlab.o

read_sparse.$(MEX_EXT):	read_sparse.cpp
	$(MEX) $(MEX_OPTION) read_sparse.cpp

svm_model_matlab.o:     svm_model_matlab.cpp svm.h
	$(CXX) $(CFLAGS) -c svm_model_matlab.cpp

svm.o:  svm.cpp svm.h
	$(CXX) $(CFLAGS) -c svm.cpp

clean:
	rm -f *~ *.o; rm -f *.mex*; rm -f *obj

