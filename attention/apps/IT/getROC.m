%-----------------------------------------------------------------------
%
%
function [det,tot,fp]=getROC(imgDir,salmapDir,imgNames,eyeData,imgRows,imgCols)
    global gDEBUG;
    nSubj = size(eyeData,1);
    nTasks= size(eyeData,2);
    nImg  = length(imgNames);
    THRESH= 0.001:0.05:1;
    NEYE  = 3;
    FACTOR= 4;
    for n=1:NEYE
        for t=1:nTasks
            det{n,t} = zeros(nSubj,length(THRESH));
            tot{n,t} = zeros(nSubj,length(THRESH));
            fp{n,t}  = zeros(nSubj,length(THRESH));
        end;
    end;
    for i=1:length(imgNames)
        [path,name,ext]=fileparts(imgNames{i});
        imgNames{i}=[name ext];
    end;
    for i=1:nImg
         fprintf('Processing %d of %d\n',i,nImg)
         fprintf('Filename:%s\n',imgNames{i});
         map     = zeros(ceil(imgRows/4),ceil(imgCols/4)); 
		 salFile = strrep(imgNames{i},'.jpg','.mat');
         load(fullfile(salmapDir,salFile),'salmap','img_file');
         assert(strcmp(img_file,imgNames{i}));
         salmap  = imresize(salmap,[imgRows/FACTOR,imgCols/FACTOR],'bicubic');
         for task=1:nTasks
            taskmap = squeeze(salmap(:,:,task));
            val     = sort(taskmap(:),'descend');
             for s=1:nSubj
                fix  =ceil(eyeData{s,task,i}/FACTOR);
    	        if(gDEBUG)
    	            img  =imread(fullfile(imgDir,imgNames{i}));
                    img  =imresize(img,[size(img,1)/FACTOR,size(img,2)/FACTOR],'bicubic');
                    [x,y]=meshgrid(1:size(img,2),1:size(img,1));
	                subplot(1,2,1);imagesc(x(1,:),y(:,1),img);axis image off;
                    hold on;contour(x(1,:),y(:,1),taskmap,quantile(val,0.8));hold off;
        	        subplot(1,2,2);imagesc(taskmap);axis image off;
                    drawnow;
    	        end;
	            for t=1:length(THRESH)
                    th   =quantile(val(:),(1-THRESH(t)));
                    msk  =taskmap>th;
                    for n=1:NEYE
                      for f=1:min(size(fix,1),n)
                        tot{n,task}(s,t)=tot{n,task}(s,t)+1;
                        y          =max(1,min(fix(f,1),imgRows/FACTOR));
                        x          =max(1,min(fix(f,2),imgCols/FACTOR));
                        if(msk(y,x))
                            det{n,task}(s,t)=det{n,task}(s,t)+1;
                        else
                            fp{n,task}(s,t)=fp{n,task}(s,t)+1;
                        end;%msk
                      end;%fixations
                    end;%NEYE
                 end;%threshold
              end;%subject
        end;%task              
    end;%i
%end function
