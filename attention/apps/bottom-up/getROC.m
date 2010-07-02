%-----------------------------------------------------------------------
%
%
function [det,tot,fp]=getROC(imgDir,salmapDir,imgNames,eyeData,imgRows,imgCols)
    global gDEBUG;
    nImg  = 120;%(imgNames);
    THRESH= 0.00:0.05:1;
    FACTOR= 2;
    det = zeros(1,length(THRESH));
    tot = zeros(1,length(THRESH));
    fp  = zeros(1,length(THRESH));
    for i=1:length(imgNames)
        [path,name,ext]=fileparts(imgNames{i});
        imgNames{i}=[name ext];
    end;
    for i=1:nImg
         fprintf('Processing %d of %d\n',i,nImg)
         fprintf('Filename:%s\n',imgNames{i});
		 salFile = strrep(imgNames{i},'.jpg','.mat');
         load(fullfile(salmapDir,salFile),'salmap','img_file');
         salmap  = imresize(salmap,[imgRows/FACTOR,imgCols/FACTOR],'bicubic');
         val     = sort(salmap(:),'descend');
         [y,x]=find(eyeData{i});
         y    =ceil(y/FACTOR);
         x    =ceil(x/FACTOR);
         fix  =[y(:),x(:)];
         if(gDEBUG)
            img  =imread(fullfile(imgDir,imgNames{i}));
            img  =imresize(img,[imgRows/FACTOR,imgCols/FACTOR],'bicubic');
            [x,y]=meshgrid(1:size(img,2),1:size(img,1));
			%timage
			t = quantile(salmap(:),[0.8,0.9,0.95]);
			val=[0.7 0.7 0.7];
			timage=zeros(size(salmap));
			for n=1:length(t)
			  idx   =find(salmap>t(n));
			  timage(idx)=val(n);
			end;
            subplot(1,2,1);
			imagesc(img_scale(BlueMask(img_scale(timage),img,0.5,[0.4 1 0.4])));
            hold on;axis image off;
			subplot(1,2,2);imagesc(img_scale(max(0,salmap-quantile(salmap(:),0.5)).^0.5),[0 1]);colormap(jet(8));axis image off;
			%hold on;contour(x(1,:),y(:,1),salmap,quantile(val,0.9),'color','red','lineWidth',2);
            %plot(fix(:,2),fix(:,1),'g+');
            %subplot(1,2,2);imagesc(salmap);axis image off;
         end;
         for t=1:length(THRESH)
                th   =quantile(salmap(:),(1-THRESH(t)));
                msk  =salmap>th;
                for f=1:min(size(fix,1),inf)
                    tot(t)=tot(t)+1;
                    y          =max(1,min(fix(f,1),imgRows/FACTOR));
                    x          =max(1,min(fix(f,2),imgCols/FACTOR));
                    if(msk(y,x))
                          det(t)=det(t)+1;
                          if(gDEBUG & THRESH(t)==0.2)
							  subplot(1,2,1);hold on;
                              plot(fix(f,2),fix(f,1),'y+','MarkerSize',3,'LineWidth',2);
                          end;
                    else
                          fp(t)=fp(t)+1;
                          if(gDEBUG & THRESH(t)==0.2)
							  subplot(1,2,1);hold on;
                              plot(fix(f,2),fix(f,1),'r+','MarkerSize',3,'LineWidth',2);
                          end;
                    end;%msk
                end;%fixations
         end;%t          
        subplot(1,2,1); hold off;
        if(gDEBUG)
            saveas(gcf,fullfile('visualization-c',sprintf('%03d.jpg',i)));
            pause(1);
        end;
    end;%i
%end function
