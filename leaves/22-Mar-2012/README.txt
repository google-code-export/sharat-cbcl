Correlation.txt:
This contains the correlation coefficient between pair-wise metrics computed from the image and phylogenetic distances. 
The pairwise metrics computed from the image are on a completely different scale from that of the phylogentic distances.
Ideally we would like to frame this a distance learning problem that calibrates and matches the two distances. For the
time being, I apply a transfer function to each of the metric and display the one that results in the highest correlation.

FAQ: What is the difference between absolute-diff-max/min/median?
Ans: The phylogentic distances are given at a finer grain than family. For instance, given two classes A andB with subdivisions
A_a, A_b and B_x,B_y phylogentic distances are provided pairs dist{A_a,B_x},dist{A_a,B_y},dist{A_b,B_x},dist{A_b,B_y}.
However, we are interested in a distance measure between A & B.
dist-max(A,B) is defined as max (dist{A_a,B_x},dist{A_a,B_y},dist{A_b,B_x},dist{A_b,B_y}).
dist-mean(A,B),dist-max(A,B),dist-min(A,B) are defined similarly.

family.txt:
This is the mean classification accuracy between families. Chance 1/19
Confusion matrix is provided in family_confusion_matrix.txt and family_confusion_matrix.jpg

order.txt
This is the mean classification accuracy between orders.
Confusion matrix is provided in order_confusion_matrix.txt and order_confusion_matrix.jpg

pairwise_accuracy.txt (confusion matrix: pairs-pairs_confusion_matrix.jpg)
pairwise_lda_separability.txt (confusion matrix: fda_pairs_confusion_matrix.jpg)
Measures pairwise distance using image features. 

fda.*dendogram(method):
A hypothesis of how the families are related based on pairwise fda similarity.

pair.*dendogram(method):
A hypothesis of how the families are related based on fda pairwise accuracy.
