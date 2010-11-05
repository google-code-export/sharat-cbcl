function img=readLeafImage(HOME,filename)
  %get magnification
  match=regexp(filename,'\[(?<mag>\d+.\d+)x\].jpg','names');
  mag=str2num(match.mag);
  %get dpi
  match=regexp(filename,'\{(?<source>.*)\}','names');
  switch(match.source)
      case 'AxelrodUCMP'
        dpi=600;
      case 'Klucking'  
        dpi=600;
      case 'WolfeUSGS'
        dpi=300;
      otherwise
        dpi=600;
  end;  
  img=imread(fullfile(HOME,filename));
  %resize
  factor=(300/dpi)/mag;
  img=imresize(img,factor,'bicubic');
%function
