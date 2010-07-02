%------------------------------------------
%
%
clear all;
close all;
addpath(genpath('~/third_party/BNT'));
addpath('~/utils');
addpath('~/cbcl-model-matlab');
addpath('~/lgn');
addpath('~/ulmann/code');
i=1;
global gSettings;
for doSN=[0,1]
    for c1Pool=[11]
        for patchSize=[7,9]
            for patchBand=[1]
                for c2Pool=[5,7,9]
                    for nPatches=[6,8,10]
                        for nFtr=[4,8,16,24]
                            for dSize=[7,9,11]
                                gSettings(i).doSN=doSN;
                                gSettings(i).c1Pool=c1Pool;
                                gSettings(i).patchSize=patchSize;
                                gSettings(i).patchBand=patchBand;
                                gSettings(i).c2Pool    =c2Pool;
                                gSettings(i).nPatches  =nPatches;
                                gSettings(i).nFtr      =nFtr;
                                gSettings(i).dSize     =dSize;
                                i                      =i+1;
                            end;
                        end;
                    end;
                end;
            end;
        end;
    end;
end;
lockDir='locks';
if(~exist(lockDir)) mkdir(lockDir); end;
for i=1:length(gSettings)
    try
    lockFile=fullfile(lockDir,sprintf('settings-%03d.lock',i));
    if(exist(lockFile))
        sprintf('%s exists\n',lockFile);
        continue;
    end;
    save(lockFile,'lockFile');
    fprintf('Processing setting:%d\n',i);
    patches= scriptGeneratePatches(gSettings(i).doSN,...
                          gSettings(i).c1Pool,...
                          gSettings(i).patchSize,...
                          gSettings(i).patchBand,...
                          gSettings(i).nPatches,...
                          gSettings(i).dSize); 

    [X,Y]=  scriptGenerateTraining(patches,...
                                   gSettings(i).doSN,...
                                   gSettings(i).c1Pool);
    [engine,pO,thresh,sel]=scriptGeneratePO(...
                                   X,Y,...
                                   gSettings(i).nFtr);
    folderName=sprintf('ftr-%03d',i);
    mapName   =sprintf('map-%03d',i);
    setFile   =sprintf('set-%03d',i);
    scriptGenerateFeatures(patches,folderName,...
                    gSettings(i).c1Pool,...
                    gSettings(i).c2Pool,...
                    gSettings(i).doSN);
    scriptRunEngine(engine,pO,thresh,sel,folderName,mapName);
    save(setFile,'X','Y','patches','gSettings','i',...
                 'engine','pO','thresh','sel')
    catch
    continue;
    end;
end;    
