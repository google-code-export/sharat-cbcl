%-------------------------------------------------------
%
%
%sharat@mit.edu
%
function p=basicjob
    %parameters
    p=struct;
    p.func=''
    p.home='imagedb';
    p.holdFraction=0.05; % porition of images used for
                         % learning feature dictionary
    p.splits=3;          % 
    %use this function as default feature extraction 
    %Alternate: hmax
    p.callback='callback_shape'; %in code/
    p.ftrlen=264;

    %classifier specificatoin
    p.classifier='libsvm'; %(can be rls,liblinear,libsvm)
                           %recommend rls
    p.minCount=100; %classes with fewer than these number of images
                    %are ignored
    p.tasks={};
    p.desc='';

    %split the files
    t=struct;
    t.name='split'
    t.args=struct;
    t.func='split_default';
    p.tasks{end+1}=t;


    %dictionary learning
    t=struct;
    t.name='flearn'
    t.args=struct;
    t.func='flearn_shape'
    t.depends={'split'};
    p.tasks{end+1}=t;


    %feature extraction
    t=struct;
    t.name='fextract';
    t.args=struct;
    t.func='fextract_shape'
    t.depends={'split'};
    p.tasks{end+1}=t;

    %feature extraction
    t=struct;
    t.name='matrix';
    t.args=struct;
    t.func='matrix_shape'
    t.depends={'fextract','flearn'};
    p.tasks{end+1}=t;

    %classification by family
    t=struct;
    t.name='family';
    t.args=struct;
    t.func='classify_family'
    t.depends={'matrix'};
    p.tasks{end+1}=t;


    %classification by order
    t=struct;
    t.name='order';
    t.args=struct;
    t.func='classify_order'
    t.depends={'matrix'};
    p.tasks{end+1}=t;

