This describes the framework for leaves recognition. The code provides 
scaffolding to evaluate new features. The feature extraction and 
classification can be done in parallel thanks to Jim Mutch's DMAKE matlab
framework. The evaluation pipeline is divided into the following stages:

a) Split creation: This stage divides the input images into training 
and testing.

b) Building feature dictionary: The previous stage also puts aside 
a small portion of images for extracting a feature dictionary. This 
stage is used to build the feature dictionary that can be used to 
extract features from both the training and test splits. This allows
us to compute an arbitrary number of splits at very little cost. 

c) Feature extraction: In this stage, the framework reads each image
and calls the function specified in the parameters. In order to 
generate feature, the only change required is to change the callback
function

d) Classification: The framework performs multi-class classification 
in parallel (using one vs all paradigm). Further more classification 
is done both according to leaf family and leaf order. 

Downloading
------------
You can download the source by using svn
svn checkout http://sharat-cbcl.googlecode.com/svn/trunk/leaves leaves

If you want to commit code changes, please send an e-mail to sharat.chikkerur@gmail.com


Code structure:
---------------
leaves/utils: contains utilities to plot results.
leaves/hmax : This is where the feature extraction utilities code
leaves/vars : Files in this directory specify the variables in your 
              work environment. Change these to point to the correct
              locations.
leaves/tasks: Custom tasks. For most purposes default task should serve
              your goal.
leaves/code : catchall dump--will be cleaned up later
orderfamily.csv: curated list of order-family mapping

Getting started
---------------
If you start matlab from the the 'leaves' folders, the startup.m file is executed automatically. Otherwise, please run startup before running any leaves-specific code. 

Setting variables (Edit the following files):
-------------------
Set the path in the following order.
a)vars/homedir.m -This serves as the base folder of the data and result. 
b)vars/datadir.m -Location that contains the leaves database. It is assumed that each order is located in a separate folder.
c)vars/featdir.m -Where the feature vectors are stored (will take lot of storage)            

Instead of copying the data folder to a new location, the locations can also be set to existing copies. A simple way of doing it is to create symbolic links in the current folder and retain the defaults.

cd /path/to/leaves
ln -s /some/big/folder/data .
ln -s /some/big/folder/feat .

Debug run
----------
%Follow setup instructions
%Set p.callback='dummy_function' in basicjob.m
cd /path/to/leaves
startup
cj trial basicjob
rj trial
report_results('trial')

Creating new jobs
--------------------------
Creating and running jobs requires creating job files (e.g. basicjob.m). Each job consists of several 'tasks' that are executed in order. A task may 
depend on several jobs in which case its dependants are executed first. Each task may be executed in parallel if it allows it. The DMake framework handles these for you. The programmer's job is to define the task and specify how it is parallelized. For now, basicjob.m provides a suitable template to evalute different features. You can simply change the callback function in that file to evaluate different features. 

Creating job:  (Single machine)
cj jobname basicjob
e.g.
> cj trial basicjob

Running job: (Can be executed simultaneously on multiple machines) 
rj jobname

e.g. 
>rj trial

Evaluation:
-------------
report_results('jobname')
e.g. report_results('trial') %will display confusion matrix and average
accuracy for the trial job. 

Writing feature extractors:
---------------------------
A new feature extractor can be written by writing a callback function and setting p.callback=newfunction in the job file (e.g. basicjob.m). The function should conform to the following parameters
  
  %img=normalized image
  %ftr=column vector of output features
  %family,order-provided for debug (DONOT use in feature extraction)
  function ftr=myfunc(img,family,order)

Classifiers:
------------
The classifier to be used can be chosen by setting p.classifier in the job file (e.g. basicjob.m). Currently the following are supported 'rls','libsvm','liblinear'. It is recommended that rls or libsvm be used, since parameters for these are chosen by 3-fold cross validation.

Problems:
---------
a)You can startover by issuing DMDeleteJob(jobname) and then calling 
cj jobname again.
