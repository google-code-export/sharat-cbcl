%----------------------------------------------
%sharat@mit.edu
close all;
clear all;
load eyeData;fixations=fixations([1 2 4],:,:);
global gDEBUG;
FACTOR  =4;
imgRows =480/FACTOR;
imgCols =480/FACTOR;
objNames={'face','monkey-face','vehicle'};
nSubj   =size(fixations,1);
nImages =size(fixations,3);
nObj    =size(fixations,2);
THRESH  =0.0:0.05:1;
NEYE    =3;
%----------------------------
%use this for task switch
objIdx  =[1 2 3]
%----------------------------
%use this for image switch
shuffleImages=1;

for e=1:NEYE
for o=1:nObj
    det{e,o}=zeros(nSubj,length(THRESH));
    tot{e,o}=zeros(nSubj,length(THRESH));
    nss{e,o}=zeros(nSubj,nImages);
    for i=1:nImages
       if(shuffleImages)
           imgIdx = randperm(nImages);
       else
           imgIdx = 1:nImages;
       end;

       for s=1:nSubj
           fprintf('Processing :%d,%d,%d,%d\n',e,o,i,s);
           salmap = zeros(imgRows,imgCols);
           ridx   = randperm(80);
           ridx   = ridx(randperm(80));
           for ss=1:nSubj
                fix = ceil(fixations{ss,objIdx(o),imgIdx(i)}/FACTOR);
                if(ss==s)continue;end;
                for f=1:min(e,size(fix,1))
                    y=min(imgRows,max(1,fix(f,1)));
                    x=min(imgCols,max(1,fix(f,2)));
                    salmap(y,x)=salmap(y,x)+1;
                end;
           end;%ss
           salmap = imfilter(salmap,fspecial('gaussian',120/FACTOR,20/FACTOR));
           [x,y]=meshgrid(1:imgCols,1:imgRows);
           salmap = salmap+1e-6*exp(-(x-imgCols/2).^2/(2*imgCols^2)-(y-imgRows/2).^2/(2*imgRows^2));
           nsalmap= (salmap-mean(salmap(:)))/(std(salmap(:))+1e-5);
           if(gDEBUG)
               fix = ceil(fixations{s,o,i}/FACTOR);
               if(~isempty(fix))
                   imagesc(1:imgCols,1:imgRows,salmap);colormap('gray');hold on;
                   contour(1:imgCols,1:imgRows,salmap,quantile(salmap(:),0.8),'color','red','lineWidth',2);
                   plot(fix(:,2),fix(:,1),'ro');
                   hold off;drawnow;
               end;
           end;
           fix = ceil(fixations{s,o,i}/FACTOR);
           %---------------------------
           %compute FMSR
           for t=1:length(THRESH)
                  th  =quantile(salmap(:),1-THRESH(t));
                  msk =salmap>th;
                  for f=1:min(e,size(fix,1))
                     y=min(imgRows,max(1,fix(f,1)));
                     x=min(imgCols,max(1,fix(f,2)));
                     tot{e,o}(s,t)=tot{e,o}(s,t)+1;
                     if(msk(y,x))
                        det{e,o}(s,t)=det{e,o}(s,t)+1;
                    end;
                  end;%f
           end;%t
           %---------------------------
           %compute NSS
           for f=1:min(e,size(fix,1))
                 y=min(imgRows,max(1,fix(f,1)));
                 x=min(imgCols,max(1,fix(f,2)));
                 nss{e,o}(s,i)=nss{e,o}(s,i)+nsalmap(y,x);
           end;
         end;%s
    end;%i
end;%o
end;%e
for i=1:NEYE;for t=1:3;area{i,t}=trapz(det{i,t}'./tot{i,t}')*0.05;end;end;
save results-switch-human det tot area
