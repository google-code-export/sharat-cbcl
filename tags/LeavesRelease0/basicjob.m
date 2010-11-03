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
    %this function is called for each image in the db
    %dummy_function can be used to test
    p.callback='dummy_function'; 
    p.ftrlen=400;
    %use this function as default feature extraction 
    %Alternate: hmax
    %p.callback='callback_hist_leaves'; %in code/
    %p.ftrlen  =193;
    
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
    t.func='flearn_default'
    t.depends={'split'};
    p.tasks{end+1}=t;


    %feature extraction
    t=struct;
    t.name='fextract';
    t.args=struct;
    t.func='fextract_default'
    t.depends={'flearn'};
    p.tasks{end+1}=t;

    %classification by family
    t=struct;
    t.name='family';
    t.args=struct;
    t.func='classify_family'
    t.depends={'fextract'};
    p.tasks{end+1}=t;


    %classification by order
    t=struct;
    t.name='order';
    t.args=struct;
    t.func='classify_order'
    t.depends={'fextract'};
    p.tasks{end+1}=t;


