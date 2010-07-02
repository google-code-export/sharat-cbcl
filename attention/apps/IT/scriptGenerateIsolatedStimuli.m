clear all;
close all;
STIM='stimuli';
for i=1:16
  imgFile=fullfile(STIM,sprintf('%d.png'));
  img    =imread(imgFile);
end;  
