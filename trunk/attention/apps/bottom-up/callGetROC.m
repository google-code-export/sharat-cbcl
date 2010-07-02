salmapDir = '/cbcl/scratch04/sharat/data/AIMBU90Clustered';
imgDir    = '/cbcl/scratch04/sharat/data/AIM/AIM'
imgRows   = 511;
imgCols   = 681;
for i=1:120
    imgNames{i}=sprintf('%d.jpg',i);
end;    
load('origfixdata','white');
[det,tot,fp] =getROC(imgDir,salmapDir,imgNames,white,imgRows,imgCols);
