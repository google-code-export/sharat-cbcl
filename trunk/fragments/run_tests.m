%--------------------------------------------------------------------------
%run_tests
% runs the test on all the image in the specified directory
% usage:
%     run_tests(root,dir,file)
%     root - (IN) properly initialized fragment hierarchy. 
%     dir  - (IN) directory name containing positive images
%     file - (IN) file where all the scores are to be written
%sharat@mit.edu
%--------------------------------------------------------------------------
function run_tests(root,fdir,file)
    dbg_flag = 0;  %switch this off if you want
    %load positive and negative images
    imgfiles   = dir(sprintf('%s/*.pgm',fdir));
       
    images = [];
    for i  = 1:length(imgfiles)
      images(i).img = imread(sprintf('%s/%s',fdir,imgfiles(i).name));
      if(dbg_flag)
	imshow(images(i).img),title(sprintf('Image:%d',i));
	pause;
      end;
    end;

    %conduct the tests and write to file
    fid = fopen(file,'w');
    for i = 1:length(imgfiles)
      fprintf('Processing--->%d\n',i);
      [res,S] = image_response(root,images(i).img);
      fprintf(fid,'%f\n',res);
      fprintf('Response-->%f\n',res);
    end;
    fclose(fid);
    
%end function
