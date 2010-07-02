clear all;
load eyeData;
imgHome='/cbcl/scratch04/sharat/gabriel/testing';
mapHome='/cbcl/scratch04/sharat/gabriel/maps7x7-adaboost';
imgFiles=dir(fullfile(imgHome,'*.jpg'));imgFiles={imgFiles.name};
imgFiles=imgFiles(randperm(length(imgFiles)));
allImages={allImages(:,1).name};

for i=1:length(imgFiles)
  salFile=fullfile(mapHome,strrep(imgFiles{i},'.jpg','.mat'));
  load(salFile,'salmap','img_file');
  imgFile=fullfile(imgHome,img_file);
  img    =imread(imgFile);
  img    =im2double(imresize(img,0.5,'bicubic'));
  idx    =find(strcmp(allImages,imgFiles{i}));
  if(isempty(idx)) continue;end;
  colors ={'r','g','b','m'};
  for nTask=1:size(fixations,2)
	sal    =salmap(:,:,nTask);
	sal    =imresize(sal,size(img),'bicubic');
    sal    =img_scale(sal);
	subplot(1,size(fixations,2),nTask);imagesc(img);colormap('gray');
    title(sprintf('%s(%d)',img_file,idx))
	hold on;axis image;colormap('gray');
	for nSubj=1:size(fixations,1)
	  fix=ceil(fixations{nSubj,nTask,idx}/2);
	  if(~isempty(fix))
		fix=fix(1:min(size(fix,1),3),:);
		plot(fix(:,2),fix(:,1),'o','color',colors{nSubj},'lineWidth',2);	
	  else
		fprintf('Subject:%d,Task:%d is empty!\n',nSubj,nTask);
	  end;
	end;
	hold off;
	%subplot(2,size(fixations,2),size(fixations,2)+nTask);imagesc(img.*sal.^2)
  end;
  pause;
end;  
