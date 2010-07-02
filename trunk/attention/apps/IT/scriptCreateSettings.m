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
warning('all','off');
i=1;
global gSettings;
for doFtrSel=[0 1]
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
                                    gSettings(i).doFtrSel=doFtrSel;
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
end;
DO_PATCHES=0;
DO_TRAINING=0;
DO_PO=1;
DO_FTR=0;
DO_ENGINE=0;
%-------------------------------------------
%select training images
%
HOME='/cbcl/scratch01/sharat/databases/Ying';
SETTINGS='settings';
img_files ={};
for obj={'car','couch','face','fruit'}
  obj=char(obj);
  tfiles=dir(fullfile(HOME,obj,'*.jpg'));
  for j=1:75
	r=randperm(length(tfiles));
	img_files{end+1}=im2double(rgb2gray(imread(fullfile(HOME,obj,tfiles(r(1)).name))));
  end;
end;
%--------------------------------------------
%
lockDir='locks';
if(~exist(lockDir)) mkdir(lockDir); end;
for i=37:length(gSettings)
    try
    folderName=fullfile(SETTINGS,sprintf('ftr-%03d',i));
    mapName   =fullfile(SETTINGS,sprintf('map-%03d.mat',i));
    setFile   =fullfile(SETTINGS,sprintf('set-%03d.mat',i));
	lockFile=fullfile(lockDir,sprintf('settings-%03d.lock',i));
    if(exist(lockFile))
        sprintf('%s exists\n',lockFile);
        continue;
    end;
    save(lockFile,'lockFile');
    fprintf('Processing setting:%d\n',i);
	if(DO_PATCHES)
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
    else
	   if(exist(setFile))
		 load(setFile,'patches');
	   end;
	end;%DO_PATCHES
	if(DO_TRAINING) 
	  [X,Y]=  scriptGenerateTraining(patches,...
		                           gSettings(i).trnSize,...
                                   gSettings(i).doSN,...
                                   gSettings(i).c1Pool,...
                                   gSettings(i).c2Pool);
				 
    else						 
	  if(exist(setFile))
		load(setFile,'X','Y');
	  end;
	end;%DO_TRAINING
	if(DO_PO)
	  [pO,thresh,sel] = scriptGeneratePO(...
                                   X,Y,...
                                   gSettings(i).nFtr,...
                                   gSettings(i).doFtrSel,...
                                   gSettings(i).xSigma);

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
    else
	  if(exist(setFile))
		load(setFile,'pO','thresh','sel','engine');
	  end;
	end;%DO_PO							   
	if(DO_FTR)
	  [trnX,trnY,tstX,tstY,tstTag]=...
		             scriptGenerateFeatures(patches,folderName,...
		             gSettings(i).trnSize,...
		             gSettings(i).c1Pool,...
                     gSettings(i).c2Pool,...
                     gSettings(i).doSN);
	  disp('Done with features');
    else		   
	   if(exist(setFile))
		 load(setFile,'trnX','trnY','tstX','tstY','tstTag');
	   end;
	end;				 
	if(DO_ENGINE)		   
	  scriptRunEngine(engine,pO,thresh,sel,folderName,mapName);
	end;
    save(setFile,'X','Y','patches','gSettings','i',...
                 'engine','pO','thresh','sel',...
				 'trnX','trnY','tstX','tstY','tstTag');
   catch
	  err=lasterror;
	  keyboard;
	  continue;
   end;
end;    
