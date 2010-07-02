for i=1:length(db)
    fprintf('%d of %d\n',i,length(db))
    imgFile=fullfile(imgHome,db(i).annotation.folder,db(i).annotation.filename);
    img    =imread(imgFile);
    [ht,wt,d]=size(img);                          
    if(ht>wt)
        img = imresize(img,[ceil(ht/wt*256) 256],'bicubic');
    else
        img = imresize(img,[256 ceil(wt/ht*256)],'bicubic');
    end;
    fprintf('%s:%dx%d\n',db(i).annotation.filename,ht,wt);
    imwrite(img,fullfile(destHome,db(i).annotation.filename));
end;

