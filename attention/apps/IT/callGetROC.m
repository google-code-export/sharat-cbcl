load eyeData;
%load objData;

salmapDir = '/cbcl/scratch04/sharat/gabriel';
imgDir    = '/cbcl/scratch04/sharat/gabriel/testing'
imgRows   = 480;
imgCols   = 480;
for type={'mi'};%,'adaboost','90'}
    salmapDir = fullfile('/cbcl/scratch04/sharat/gabriel',sprintf('maps7x7-%s',char(type)))
    if(0)
        %---------------------
        %target-mi
        imgNames= {allImages(:,1).name};fileNames=imgNames(1:40);eyeData=fixations(:,:,1:40);
        [det,tot] =getROC(imgDir,salmapDir,fileNames,eyeData,imgRows,imgCols)
        for n=1:3;for t=1:3;area{n,t}=trapz(det{n,t}'./tot{n,t}')*0.05;end;end;
        save(sprintf('results-pos-%s',char(type)),'det','tot','area');
        %---------------------
        %distractor-mi
        clear det tot area;
        imgNames= {allImages(:,1).name};fileNames=imgNames(41:80);eyeData=fixations(:,:,41:80);
        [det,tot] =getROC(imgDir,salmapDir,imgNames,fixations,imgRows,imgCols)
        for n=1:3;for t=1:3;area{n,t}=trapz(det{n,t}'./tot{n,t}')*0.05;end;end;
        save(sprintf('results-neg-%s',char(type)),'det','tot','area');
    end;
    %---------------------
    %target-mi
    imgNames= {allImages(:,1).name};fileNames=imgNames;eyeData=fixations(:,:,:);
    [det,tot,fp] =getROC(imgDir,salmapDir,fileNames,eyeData,imgRows,imgCols)
    for n=1:3;for t=1:3;area{n,t}=trapz(det{n,t}'./tot{n,t}')*0.05;end;end;
    %save(sprintf('results-%s',char(type)),'det','tot','area','fp');
end;    
