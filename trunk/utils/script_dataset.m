%--------------------------------------------------------------------
%
%sharat@mit.edu
%--------------------------------------------------------------------
 HOME            = '/cbcl/scratch03/sharat/manu';
 EXT             = 'jpg';
 CALLBACK        = 'callback_c2_baseline';
 PATCH_CALLBACK  = 'get_dictionary_patches';
 PATCHES_PER_IMAGE  = 20;
 SKIP_BACKGROUND    = 0;
 % ---------------------------
 %scan through the classes
 %---------------------------
 dir_class      = dir(HOME);
 dir_class      = dir_class(3:end);
 cls_lbl        = 1:length(dir_class);

 trn_idx       = 1;
 tst_idx       = 1;

  fprintf('Scanning directory for training and testing images\n');
  %---------------------------------
  %fetch files
  %----------------------------------
  for i = 1:length(dir_class)
    fprintf('Processing directory: %s(%d of %d)\n',dir_class(i).name,i,length(dir_class));
    files = dir(fullfile(HOME,dir_class(i).name,sprintf('*.%s',EXT)));
    fprintf('Total files:%d\n',length(files));
    for j = 1:length(files)
      trn(trn_idx).name = fullfile(HOME,dir_class(i).name,files(j).name);
      trn(trn_idx).class= i;
      trn_idx           = trn_idx+1;
    end;
  end;
  X       = [];
  Y       = [];
  patches = patches_c2m;
  for i = 1:length(trn)
    fprintf('Extracting %d of %d\n',i,length(trn));
    img = imread(trn(i).name);
    if(size(img,3)~=1)
      img = rgb2gray(img);
    end;
    img = im2double(img);
    ftr = feval(CALLBACK,img,patches);
    X   = [X,ftr(:)];
    Y   = [Y,trn(i).class];
  end;
%end;
