%----------------------------------------------------------------------------
%
%sharat@mit.edu
%---------------------------------------------------------------------------
clear all;
close all;
HOME   ='/data/scratch/sharat/data';
TARGET ='leaves-ftr';
PREFIX ='split_c2_%03d_results.mat';
SPLITS =5;
if(1)
addpath(fullfile(HOME,'ssdb'));
addpath(fullfile(HOME,'utils'));
addpath(fullfile(HOME,'lgn'));
addpath(fullfile(HOME,'leaves'));
img_err=hashtable;
img_lbl=hashtable;
for s = 1:SPLITS
	fprintf('Processing split:%d\n',s);
	result_file=fullfile(HOME,TARGET,sprintf(PREFIX,s));
	load(result_file,'tst_lbl');
	%-----------------------------------
	%testing
	%-----------------------------------
	TRIAL			   = 2;
	[tstX,tstY,img_set]= aggregate_ftr(fullfile(HOME,TARGET),s,0);
	tstY               = tstY-2;
	tstX(tstY==7,:)    = [];   %copy error
	img_set(tstY==7)   = [];
	tstY(tstY==7)      = [];   %copy error
	lbl                = tst_lbl{TRIAL};
	for i=1:length(img_set)
	  if(tstY(i)~=lbl(i))
		cnt = img_err(img_set{i});
		if(isempty(cnt))
			cnt = 1;
		else
			cnt = cnt + 1;
		end;
		img_err(img_set{i})=cnt;
	  end;%err
	  img_lbl(img_set{i})=tstY(i);
	end;
end;
end;
CLASSES={'Annonaceae','Betulaceae','Bignoniaceae',...
'Burseraceae','Caesalpinioidiae','Celastraceae',...
'Copiade-Annonaceae','Ericaceae','Fagaceae',...
'Hamamelidaceae','Lauraceae'};
%--------------------------------------------------------------
%dump the image files
%--------------------------------------------------------------
idx  = 1;
hkeys= keys(img_err);
for i= 1:length(hkeys) 
    k          = hkeys{i};
   dest_lbl    = img_lbl(k);
   dest_err    = img_err(k);
   dest_folder = fullfile('error',CLASSES{dest_lbl});
   if(~exist(dest_folder))
	mkdir(dest_folder);
   end;
   dest_name   = sprintf('%d_%d.jpg',idx,dest_err);
   system(sprintf('cp %s %s',k,fullfile(dest_folder,dest_name))); 
   idx         = idx+1;
end;

