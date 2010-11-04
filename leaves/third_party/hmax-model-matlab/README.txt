Files       Description
========================
demo.m					Shows how to use the model on a toy dataset (see weizmann folder)
patches_gabor.mat		Contains the default gabor patches
create_c0.m             Creates the initial image pyramid
s_norm_filter.m         Computes S layer using normalized dot product operation
s_grbf.m                Computes S layer using gaussian radial basis function
c_local.m               Computes C layer by local spatial/scale pooling
c_global.m              Computes C layer by global pooling
get_c_patches.m         Generate shape prototypes by sampling C1 outputs from a cell array of images
learn_c_patches.m       Generates shape prototypes by clustering C1 outputs from a cell array of images (experimental,not recommended)


callback_c1_baseline.m  Wrapper function to compute c1 features from an image
callback_c2_baseline.m  Wrapper function to compute c2 features from an image
script_timing.m         Script to time different operations

