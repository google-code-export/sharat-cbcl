%------------------------------------------------------
%sharat@mit.edu
addpath('~/utils');
addpath('~/lgn');
addpath('~/ulmann/code');
addpath(genpath('~/third_party/stprtool'));
addpath(genpath('~/third_party/libsvm'));
addpath(genpath('~/third_party/classif'));
imgHome='/cbcl/scratch04/sharat/gabriel';
load patches_gabor;
load set2-051 patches;
load stock_image tst_img tst_lbl;
Y=tst_lbl;
Y=remap(Y,{[0:2],[3],[4],[5],[6],[7:8]},[4,1,2,4,3,4]);
%compute all features first
if(0)
X={[],[],[],[]};
for i=1:length(Y)
	img=tst_img{i};
    img=imresize(img,[100 100],'bicubic');
	img=img-mean(img(:));
	img=img./std(img(:));
	img=1./(1+exp(-img));
    ftr=callbackGabriel(img,patches_gabor,patches,11,5,0);
    c1 =c12vec(ftr{1});
    c2 =ftr{2}(:);
    c2b=ftr{3};
    img=imresize(img,0.5,'bicubic');
    X{1}=cat(2,X{1},img(:));%pixel features
    X{2}=cat(2,X{2},c1(:)); %c1
    X{3}=cat(2,X{3},c2(:)); %c2
    X{4}=cat(2,X{4},c2b(:));%c2b
end;    
else
    load training_data X Y
    idx=find(Y<=3);
    Y  =Y(idx);
end;

for f=1:length(X)
    X{f}  =double(X{f}(:,idx));
    %----------------------------
    %perform LOO training
    trnIdx=1:length(Y);
    tstY  =[];
    for i=1:length(Y)
        mX        =mean(X{f},2);
        sX        =double(std(X{f},[],2));
        X{f}      =X{f}-repmat(mX(:),1,size(X{f},2));
        X{f}      =spdiag(double(1./(sX+1e-4)))*X{f};
        trnX      =X{f}(:,find(trnIdx~=i));
        trnY      =Y(trnIdx~=i);
        %model     =cvLeastSquareReguM(trnX,trnY);
        %[yhat,lbl]=LeastSquareReguMC(X{f}(:,i),model);
        model     =svmtrain(trnY(:),trnX','-t 0 -w1 1 -w2 1 -w3 1 -w4 0.25 -c 0.02');
        lbl       =svmpredict(Y(i),X{f}(:,i)',model);
        tstY(i)   =lbl;
    end;
    CM{f}=confusion_matrix(Y,tstY,unique(Y));
end;    
