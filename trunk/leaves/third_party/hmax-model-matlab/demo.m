%----------------------------------------------------------------------
%shows how to use cbcl-model-matlab. 
%The weizmann dataset (face,car,aeroplanes) are used to demonstrate
%the working of the model
%
%sharat@mit.edu
%--------------------------------------------------------------------
clear all;
close all;
warning('off','all');
SVM_PATH='~/third_party/libsvm'; %CHANGE THIS
DATA_PATH='./weizmann';
SPLITS=1;
LEARN_PATCHES=0; %set to zero if patches should be sampled
                 %learn_c_patches is experimental. Pl. don't use for now
addpath(genpath(SVM_PATH));
%--------------------
%read the images
%
imgidx =1;
classes=dir(DATA_PATH);classes=classes(3:end);
for c=1:length(classes)
  files=dir(fullfile(DATA_PATH,classes(c).name,'*.pgm'));
  for f=1:length(files)
	images{imgidx}=im2double(imread(fullfile(DATA_PATH,classes(c).name,files(f).name)));
	Y(imgidx)=c; %label
	imgidx=imgidx+1;
  end;
end;

for s=1:SPLITS
  fprintf('Processing split:%d\n',s);
  %--------------------
  %split to train and test
  %
  nTrain=floor(length(Y)/2);
  idx=randperm(length(Y));
  trnIdx=idx(1:nTrain);
  tstIdx=idx(nTrain+1:end);
  %----------------------
  %extract training patches
  load patches_gabor; %gabor filters
  if(LEARN_PATCHES)
	%learn patches
	patches=learn_c_patches(images(trnIdx),'callback_c1_baseline',patches_gabor,10);
  else
	patches=get_c_patches(images(trnIdx),[1],'callback_c1_baseline',patches_gabor,2);
	patches=patches(randperm(length(patches)));
	patches=patches(1:min(64,length(patches)));%select 100 patches
  end;
  visualize_patches(patches,1);drawnow;
  disp('Press any key to continue');pause(3);
  trnX=[];trnY=[];
  tstX=[];tstY=[];
  %-----------------------
  %extract training features
  for i=1:length(trnIdx)
	fprintf('Generating training data:%d of %d\n',i,length(trnIdx));
	ftr=callback_c2_baseline(images{trnIdx(i)},patches_gabor,patches);
 	trnX(i,:)=ftr{3}(:);
	trnY(i)  =Y(trnIdx(i));
  end;

  %-----------------------
  %extract testing features
  for i=1:length(tstIdx)
	fprintf('Generating testing data:%d of %d\n',i,length(tstIdx));
	ftr=callback_c2_baseline(images{tstIdx(i)},patches_gabor,patches);
 	tstX(i,:)=ftr{3}(:);
	tstY(i)=Y(tstIdx(i));
  end;
  %------------------------
  %train svm
  %
  model=svmtrain(trnY(:),trnX,'-t 0');
  %--------------------------
  %evaluate
  disp('Training accuracy:');
  [lbl,acc,y]=svmpredict(trnY(:),trnX,model);
  disp('Testing accuracy:');
  [lbl,acc,y]=svmpredict(tstY(:),tstX,model);
end;  
