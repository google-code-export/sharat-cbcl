clear all;
close all;
SETTINGS='settings';
files=dir(fullfile(SETTINGS,'set-*.mat'));
for f=1:length(files)
    setFile=fullfile(SETTINGS,files(f).name);
end;    
