%------------------------------------------------------------------------
%hierarchy_demo
%Demo for testing hierarchical fragment based classifier.
%based on boris epshtein's "Feature Hierarchies for Object Classification",
%ICCV 05. 
%
%sharat@mit.edu
%-----------------------------------------------------------------------
dir_train_class       = '/cbcl/scratch01/sharat/cropped_irvine_images/books';
dir_train_nonclass    = '/cbcl/scratch01/sharat/cropped_irvine_images/zbackground';
dir_test_class        = '/scratch2/sharat/testing/face';
dir_test_nonclass     = '/scratch2/sharat/testing/non-face';

file_train_class      = 's_train_face';
file_train_nonclass   = 's_train_non-face';
file_test_class       = 's_test_face';
file_test_nonclass    = 's_test_non-face';

%initialize root
root  = initialize_root(dir_train_class,dir_train_nonclass);
root  = get_fragment_hierarchy(root);save tmp_root;
%root  = get_optimal_roi(root); save tmp_roi;
%root  = learn_weights(root); save tmp_net;
%run tests
%run_tests(root,dir_train_class,file_train_class);
%run_tests(root,dir_train_nonclass,file_train_nonclass);
%load tmp_net;
%run_tests(root,dir_test_class,file_test_class);
%run_tests(root,dir_test_nonclass,file_test_nonclass);

%end function hierarchy_demo


