clear all;
close all;
DATA_HOME='/cbcl/scratch01/sharat/databases/kyoto';
SETTINGS='kyoto';
addpath('~/third_party/cudaconv');
addpath('~/utils');
img_set={};
imgfiles=dir(fullfile(DATA_HOME,'osLM*.mat'));
for i=1:length(imgfiles)
  load(fullfile(DATA_HOME,imgfiles(i).name),'OL');
  img_set{i}(:,:,1)=preProcess(OL);
  imagesc(img_set{i});colormap('gray');drawnow;
end;

sIdx=1; %setting idx
gSettings=struct
for fsz=[7 11 15]
  dsz=2*fsz+1;
  for nfilt=[4 6 8]
	gSettings(sIdx).fsz=fsz;
	gSettings(sIdx).dsz=dsz;
	gSettings(sIdx).nfilt=nfilt;
	sIdx=sIdx+1;
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
								   150);
    save(resFile,'model','gSettings','i');							   
end;							   

