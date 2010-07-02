This is the public domain implementation of  Boris Epshtein's "Feature Hierarchies for Object Classification",
ICCV 05. We have tried to make it as faithful to the paper as possible. You'll need to have 
matlab image processing and neural network toolbox in order to run this code. Training takes 
about a day's computational time on a dual processor. The code is self-documented and contains a debug
flag in each file to switch on visualization. The release should contain the following zip files. For bug
reports and other comments please contact sharat@mit.edu. 


code.zip -   This contains all the matlab scripts.
trees.zip-   This contains visualization of the trained hierarchies(produced by html_tree.m)
results.zip -This contains the score files for the test set
nets.zip -   This contains the trained hierarchies for four object classes in caltech.
data.zip -   The training and test splits for each class. The split contains 4 classes
             1. Caltech Faces
             2. Caltech Leaves
             3. Weizmann Cows
             4. Weizmann Faces
             5. Caltech Motorcycles
             The wface and cows were downloaded from
	     Epshtein's weizmann dataset.The face,motors and leaves dataset were downloaded from the caltech 
             repository. Please cite the respective sources when quoting these results. 

The following are the main matlab scripts
-----------------------------------------
hierarchy_demo.m - This file contains an example of how to run the code. 
visualize_tree.m - Presents the contents of the tree hierarchy. 
html_tree.m      - Creates a web-page with tree visualization.

The following are helper files that are not directly called by the user. (alphabetical)
------------------------------------------------------------------------
cmim	           	- Computes mutual information between two variables.
corr_image       	- Computes normalizes cross correlation
detect_object	  	- Uses a sliding window at multiple scales to detect the object. 
entropy	        	- Computes entropy of a discreted RV
get_fragment_hierarchy	- Main recursive call that builds the tree
get_network             - Creates a neural network overlaying the tree
get_patches             - extracts patches from the image set (all images, all sizes)
get_fixed_size_patches  - extracts patches from a regular grid (32x32 spaced by 8 pixels by default)
get_thresh_mi           - Computes best threshold based on MI criterion
get_optimal_roi         - Performs ROI optimization after first training pass
get_best_patches 	- Selects the most relevant features based on MI criterion
get_corr_score        	- Compute correlation for a set of images. 
image_response          - Computes the response of the tree to a single image
initialize_root		- Initializes the tree. The data structure is documented in the code. 
learn_weights           - Backpropagation training for the tree weights.Uses bayesian regularization
transfer_weights        - Transfer weights from the neural network to the tree
run_tests               - Computes responses of the tree to a set of images from the given directory

