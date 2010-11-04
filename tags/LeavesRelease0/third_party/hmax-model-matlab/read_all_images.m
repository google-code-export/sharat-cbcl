%--------------------------------------------------------------------------
%
% read_images = 0 -> read file names
% read_images = 1 -> read full images 
% sharat@mit.edu
%--------------------------------------------------------------------------
function [img_cell,Y] = read_all_images(dir_name,ext,max_images,read_images)
if(nargin<2) ext        = {'jpg'}; end;
if(nargin<3) max_images = inf; end;
if(nargin<4) read_images= 0; end;

img_files = [];
%-----------------------------------------
%get list of file names to be processed
%-----------------------------------------
classes  = dir(dir_name);
img_files= {}; 
img_cell = {};
Y        = [];
idx   = 1;
for i = 1:length(classes)
 if(~isdir(fullfile(dir_name,classes(i).name)))
  continue;
 end;
 if(strcmp(classes(i).name,'.') | strcmp(classes(i).name,'..'))
 	continue;
 end;

 img_files=read_single_folder(fullfile(dir_name,classes(i).name),ext,max_images);
 fprintf('FOLDER:%s, FILES:%d\n',classes(i).name,length(img_files));
 img_cell           = cat(2,img_cell,img_files);
 Y                  = cat(1,Y,idx*ones(length(img_files),1));
 idx                = idx+1;
end
%---------------------------------------------
%convert to images if needed
%---------------------------------------------
if(read_images)
 for i = 1:length(img_cell)
    %fprintf('reading image:%s\n',img_cell{i});
	img_cell{i}=imread(img_cell{i});
 end;
end;
fprintf('done.\n');

function img_files = read_single_folder(folder,ext,max_files)
  d         = [];
  img_files = {};
  for e = 1:length(ext)
    d=cat(1,d,dir(fullfile(folder,['*.' ext{e}])));
  end;%end extension
  d      = d(randperm(length(d)));
  d      = d(1:min(length(d),max_files));
  %get file names
  for i=1:length(d)
    img_files{i}=fullfile(folder,d(i).name);
  end;

