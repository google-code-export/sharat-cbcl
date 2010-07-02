function [trnX,trnY,tstX,tstY,tstTag]=scriptGenerateFeatures(patches,...
                                folderName,...
                                trnSize,c1Pool,c2Pool,doSN)
ftrHome=folderName;
imgHome='testing';
load patches_gabor;
if(~exist(ftrHome))
  mkdir(ftrHome);
end;

%--------------------------------------------
%extract training data
%
load stock_image tst_img tst_lbl
trnX=[];trnY=[];tstX=[];tstY=[];tstTag={};

for i=1:length(tst_img)
  fprintf('Processing training:%d\n',i);
  img=im2double(tst_img{i});
  img=imresize(img,trnSize/size(img,1),'bicubic');
  ftr=callbackGabriel(img,patches_gabor,patches,...
	                  c1Pool,c2Pool,doSN);
  trnX=cat(1,trnX,ftr{3}(:)');
  trnY=cat(1,trnY,tst_lbl(i));
end;
  
%--------------------------------------------
%extract testing data
%
imgFiles=dir(fullfile(imgHome,'*.png'));
for i=1:length(imgFiles)
  fprintf('Processing:%s',imgFiles(i).name);
  [path,name,ext]=fileparts(imgFiles(i).name);
  ftrFile        =fullfile(folderName,[name '.mat']);
  img            =imread(fullfile(imgHome,imgFiles(i).name));
  img            =im2double(img);
  %magic number 128 is because of the size of the 
  %individual objects within the composite image
  img            =imresize(img,trnSize/128,'bicubic');
  ftr            =callbackGabriel(img,...
                         patches_gabor,patches,...
                         c1Pool,c2Pool,doSN);
  %parse tag
  ntag           =sscanf(name,'%1d%02d%02d%02d');
  switch(ntag(1))%condition
	case 0
	  lbl=sum(ntag(2:end));
	otherwise
	  lbl=ntag(ntag(1)+1);
  end;
  tstX           =cat(1,tstX,ftr{3}(:)');
  tstY           =cat(1,tstY,lbl);
  tstTag         =cat(1,tstTag,name);
  save(ftrFile,'ftr','img');
end;  
