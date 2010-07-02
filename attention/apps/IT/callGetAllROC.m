load eyeData;

salmapDir = '/cbcl/scratch04/sharat/gabriel';
imgDir    = '/cbcl/scratch04/sharat/gabriel/testing'
imgRows   = 480;
imgCols   = 480;
mapDirs   = dir(fullfile(salmapDir,'map9-*'));
mapArea   = [];
mapName   = {};
cnt       = 0;
for    i=1:length(mapDirs)
    type      = mapDirs(i).name;
    salmapDir = fullfile('/cbcl/scratch04/sharat/gabriel',char(type));
    mapFiles  = dir(fullfile(salmapDir,'*.mat'));
    if(length(mapFiles)~=200)
        fprintf('Not complete:%s\n',salmapDir);
        continue;
    end;
    %---------------------
    %target-mi
    imgNames= {allImages(:,1).name};fileNames=imgNames;eyeData=fixations(:,:,:);
    [det,tot,fp] =getROC(imgDir,salmapDir,fileNames,eyeData,imgRows,imgCols)
    for n=1:3;for t=1:3;area{n,t}=trapz(det{n,t}'./tot{n,t}')*0.05;end;end;
    %---------------------
    %record
    cnt  =cnt+1;
    mapArea(cnt)=0;mapName{cnt}=char(type);
    for t=1:3; 
        mapArea(cnt)=mapArea(cnt)+mean(area{3,t})/3;    
    end;   
    mapArea
    pause(1);
    save(sprintf('results/results-%s',char(type)),'det','tot','area','fp');
end;    
