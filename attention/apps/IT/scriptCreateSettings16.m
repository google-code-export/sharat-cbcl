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
addpath('~/tisom');
i=1;
global gSettings;
for doSampling=[0]
  for doSN=[0]
    for c1Pool=[11]
        for patchSize=[5,7]
            for patchBand=[1]
                for c2Pool=patchSize
				  for nPatches=[4,6,8]
                        for nFtr=[4,8]
                            for dSize=patchSize
                                for xSigma=[0.5]
								  for trnSize=[64 96 128]
									gSettings(i).doSampling=doSampling; 
                                    gSettings(i).doSN=doSN;
                                    gSettings(i).c1Pool=c1Pool;
                                    gSettings(i).patchSize=patchSize;
                                    gSettings(i).patchBand=patchBand;
                                    gSettings(i).c2Pool    =c2Pool;
                                    gSettings(i).nPatches  =nPatches;
                                    gSettings(i).nFtr      =nFtr;
                                    gSettings(i).dSize     =dSize;
                                    gSettings(i).xSigma    =xSigma;
									gSettings(i).trnSize   =trnSize;
                                    i                      =i+1;
								  end;
                                end;
                            end;
                        end;
                    end;
                end;
            end;
        end;
    end;
  end;
end;

%-------------------------------------------
%select training images
%
load stock_image
img_files =tst_img;
%--------------------------------------------
%
lockDir='locks';
if(~exist(lockDir)) mkdir(lockDir); end;
for i=1:length(gSettings)
    try
    lockFile=fullfile(lockDir,sprintf('settings16-%03d.lock',i));
    if(exist(lockFile))
        sprintf('%s exists\n',lockFile);
        continue;
    end;
    save(lockFile,'lockFile');
    fprintf('Processing setting:%d\n',i);
    if(gSettings(i).doSampling)
        patches= scriptGeneratePatchesBySampling(img_files,...
			                  gSettings(i).trnSize,...
			                  gSettings(i).doSN,...
                              gSettings(i).c1Pool,...
                              gSettings(i).patchSize,...
                              gSettings(i).patchBand,...
                              gSettings(i).nPatches,...
                              gSettings(i).dSize); 
    else
        patches= scriptGeneratePatches(img_files,...
			                  gSettings(i).trnSize,...
			                  gSettings(i).doSN,...
                              gSettings(i).c1Pool,...
                              gSettings(i).patchSize,...
                              gSettings(i).patchBand,...
                              gSettings(i).nPatches,...
                              gSettings(i).dSize); 
    end;
    [X,Y]=  scriptGenerateTraining(patches,...
		                           gSettings(i).trnSize,...
                                   gSettings(i).doSN,...
                                   gSettings(i).c1Pool,...
                                   gSettings(i).c2Pool);
    [pO,thresh,sel] = scriptGeneratePO(...
                                   X,Y,...
                                   gSettings(i).nFtr,...
                                   gSettings(i).xSigma);
    folderName=fullfile('settings16',sprintf('ftr-%03d',i));
    mapName   =fullfile('settings16',sprintf('map-%03d',i));
    setFile   =fullfile('settings16',sprintf('set-%03d',i));
    %---------------------------------
    %order the features
    [val,idx] =sort(sel);
    thresh    =thresh(idx);
    sel       =sel(idx);
    pO        =pO(idx,:);
    %--------------------------------------
    %find feature corresponding to patches
    validIdx  =sel(sel<=length(patches));
	extraIdx  =sel(sel>length(patches))-length(patches);
    patches   =patches(validIdx);
    sel       =[1:length(patches),length(patches)+extraIdx];

    engine    =buildEngine({[15 15]},gSettings(i).xSigma,0.1,pO);
    %scriptGenerateFeatures(patches,folderName,...
    %                gSettings(i).c1Pool,...
    %                gSettings(i).c2Pool,...
    %                gSettings(i).doSN);
    %scriptRunEngine(engine,pO,thresh,sel,folderName,mapName);
    save(setFile,'X','Y','patches','gSettings','i',...
                 'engine','pO','thresh','sel')
    catch
    err=lasterror;
    keyboard;
    continue;
    end;
end;    
