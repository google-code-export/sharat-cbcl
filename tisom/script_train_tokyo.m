clear all;
close all;
DATA_HOME='/cbcl/scratch01/sharat/databases/kyoto';
SETTINGS='kyoto';
img_set={};
imgfiles=dir(fullfile(DATA_HOME,'osLM*.mat'));
for i=1:length(imgfiles)
  load(fullfile(DATA_HOME,imgfiles(i).name),'OL');
  img_set{i}(:,:,1)=OL;
  imagesc(img_set{i});drawnow;
end;

sIdx=1; %setting idx
gSettings
for fsz=[7 11 15]
  dsz=2*fsz+1;
  for nfilt=[4 6 8]
	gSetting(sIdx).fsz=fsz;
	gSetting(sIdx).dsz=dsz;
	gSettings(sIdx).nfilt=nfilt;
	sIdx=sIdx;
  end;	
end;  

for i=1:length(gSettings)
  	%lock for concurrent processing
	lockFile=sprintf(fullfile(SETTINGS,sprintf('settings_%03d.lock',i)));
	resFile=sprintf(fullfile(SETTINGS,sprintf('model_%03d.mat',i)));
	
	if(exist(lockFile))
	  fprintf('%s exists!\n');
	  continue;
	end;
	save(lockFile,'lockFile');
	model=train_dictionary(img_set,gSettings(i).dsz,...
		                           gSettings(i).fsz,...
								   gSettings(i).nfilt,...
								   100);
    save(resFile,'model','gSettings','i');							   
end;							   

