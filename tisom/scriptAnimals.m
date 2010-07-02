clear all;
close all;
addpath('~/lgn');
addpath('~/utils');

imgHome='/cbcl/scratch01/sharat/databases/AnimalAude/TrainImages';
idx        =1;
imgSet     ={};
for imgPath={'Animals','Non-Animals'}
  imgDir =dir(fullfile(imgHome,char(imgPath),'*.pgm'));
  imgDir =imgDir(randperm(length(imgDir)));
  for i=1:min(50,length(imgDir))
	fprintf('reading image:%d of %d\n',i,length(imgDir));
	img          =imread(fullfile(imgHome,char(imgPath),imgDir(i).name));
	img          =preProcess(img);
	imgSet{idx}  =img;
	idx          =idx+1;
  end;
end;
model=train_dictionary(imgSet,11,5,4,100);
%load modelL1;
for i=1:length(imgSet)
   fprintf('Processing :%d of %d\n',i,length(imgSet));
   [out,res]=quantize_domain(imgSet{i},model);
   imagesc(out);colormap('gray');pause;
   imgSet{i}=res;
end;
model=train_dictionary(imgSet,7,3,5,100);
keyboard;
  
