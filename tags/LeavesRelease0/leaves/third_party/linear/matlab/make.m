% This make.m is used under Windows

mex -O -largeArrayDims -c ../blas/*.c -outdir ../blas
mex -O -largeArrayDims -c ../linear.cpp
mex -O -largeArrayDims -c ../tron.cpp
mex -O -largeArrayDims -c linear_model_matlab.c -I../
mex -O -largeArrayDims train.c -I../ tron.o linear.o linear_model_matlab.o ../blas/*.o
mex -O -largeArrayDims predict.c -I../ tron.o linear.o linear_model_matlab.o ../blas/*.o
mex -O -largeArrayDims libsvmread.c
mex -O -largeArrayDims libsvmwrite.c
