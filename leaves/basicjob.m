%-------------------------------------------------------
%
%
%sharat@mit.edu
%
function p=basicjob
    %parameters
    p=struct;
    p.func=''
    p.home=datadir;
    p.holdFraction=0.05; % porition of images used for
                         % learning feature dictionary
    fprintf('Home:%s\n',p.home)
    p.splits=10;          % 
    %this function is called for each image in the db
    %dummy_function can be used to test
    p.callback='dummy_function'; 
    p.ftrlen=400;
    %use this function as default feature extraction 
    %Alternate: hmax
    %p.callback='callback_hist_leaves'; %in code/
    %p.ftrlen  =384;
    %use this function to call pyramidal HoG features
    %
    %p.callback='call_phog'; %in code/
    %p.ftrlen  =2040;
    %classifier specificatoin
    p.classifier='rls'; %(can be rls,liblinear,libsvm)
                           %recommend rls
    p.minCount= 100; %classes with fewer than these number of images
                    %are ignored
    p.tasks={};
    p.desc='';

    %initialize
    t=struct;
    t.name='initialize'
    t.args=struct;
    t.func='initialize_default';
    p.tasks{end+1}=t;

    %dictionary learning
    t=struct;
    t.name='flearn'
    t.args=struct;
    t.func='flearn_default'
    t.depends={'initialize'};
    p.tasks{end+1}=t;


    %feature extraction
    t=struct;
    t.name='fextract';
    t.args=struct;
    t.func='fextract_default'
    t.depends={'initialize','flearn'};
    p.tasks{end+1}=t;

    %classification by family
    t=struct;
    t.name='family';
    t.args=struct('label_field','familyid');
    t.func='classify_default'
    t.depends={'initialize','fextract'};
    p.tasks{end+1}=t;

    %classification by family
    t=struct;
    t.name='randomFamily';
    t.args=struct('label_field','random_familyid');
    t.func='classify_default'
    t.depends={'initialize','fextract'};
    p.tasks{end+1}=t;


    %classification by order
    t=struct;
    t.name='order';
    t.args=struct('label_field','orderid');
    t.func='classify_default'
    t.depends={'initialize', 'fextract'};
    p.tasks{end+1}=t;

    %classification by order
    t=struct;
    t.name='randomOrder';
    t.args=struct('label_field','random_familyid');
    t.func='classify_default'
    t.depends={'initialize','fextract'};
    p.tasks{end+1}=t;

    %get pairwise classification
    t=struct;
    t.name='pairs'
    t.args=struct
    t.func='all_pairs'
    t.depends={'fextract'}
    %p.tasks{end+1}=t
   

