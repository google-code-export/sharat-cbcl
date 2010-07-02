%-------------------------------------------------------------------------
%
%sharat@mit.edu
%-------------------------------------------------------------------------
function script_process_images
C2DIR  ='/cbcl/scratch04/sharat/data/HondaC2Ex';
DESTDIR='/cbcl/scratch04/sharat/data/HondaItti'
if(~exist(DESTDIR))
    mkdir(DESTDIR)
end;    
c2Files=dir(fullfile(C2DIR,'C2_01*.mat'));
for i=1:length(c2Files)
    fprintf('Processing:%d of %d\n',i,length(c2Files));
    load(fullfile(C2DIR,c2Files(i).name));
    close all;
    img = imread(img_file);
    img = imresize(img,0.25,'bicubic');
    runSaliency(img);
    [path,name,ext]=fileparts(img_file);
    figure(2);gca;axis image off;saveas(gcf,fullfile(DESTDIR,[name '.jpg']))
    pause(1);
end; 
