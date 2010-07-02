%------------------------------------------------------------------------------
%
%
%sharat@mit.edu
%-------------------------------------------------------------------------------
clear all;
close all;
imgCols  = 681;
imgRows  = 511;
imgHome  = '/cbcl/scratch04/sharat/data/AIM/AIM';
allImages={};
fixations={};
sFolders=dir('Raw');
sFolders=sFolders(3:end);
for s=1:length(sFolders)
    for i=1:120
        imgFile=fullfile(imgHome,sprintf('%d.jpg',i));
        fixFile=fullfile('Raw',sFolders(s).name,sprintf('%d.fix.txt',i));
        img    =imread(imgFile);
        fid    =fopen(fixFile);
        pos    =textscan(fid,'%d %d');
        xpos   =min(imgCols,max(1,pos{1}*0.6652));
        ypos   =min(imgRows,max(1,pos{2}*0.6652));
        fixations{s,1,i}=[ypos(:),xpos(:)];
        imagesc(1:imgCols,1:imgRows,img);axis image;hold on;
        plot(xpos,ypos,'ro');hold off;
        pause(0.5);
		fclose(fid);
    end;
end;    
