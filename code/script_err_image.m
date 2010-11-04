%----------------------------------------------------------------------------
%
%sharat@mit.edu
%---------------------------------------------------------------------------
clear all;
close all;
HOME   ='/data/scratch/sharat/data';
TARGET ='leaves-ftr';
PREFIX ='split_c2_%03d_results.mat';
SPLITS =10;
addpath(fullfile(HOME,'ssdb'));
addpath(fullfile(HOME,'utils'));
addpath(fullfile(HOME,'lgn'));
img_err=hashtable;
img_lbl=hashtable;
img_cnt=hashtable;
for s = 1:SPLITS
	fprintf('Script: %d of %d\n',s,SPLITS);
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
	  %-----------------------
	  %update img_cnt
	  cnt = img_cnt(img_set{i});
	  if(isempty(cnt))
		cnt = 1;
	  else
		cnt = cnt+1;
	  end;
	  img_cnt(img_set{i})=cnt;
	  %----------------
	  %update img_err
	  if(tstY(i)~=lbl(i))
		cnt = img_err(img_set{i});
		if(isempty(cnt))
			cnt = 1;
		else
			cnt = cnt + 1;
		end;
		img_err(img_set{i})=cnt;
	  end;%err
	  %-----------------
	  %update img_lbl
	  img_lbl(img_set{i})=tstY(i);
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
fid   = fopen('file-list.txt','w');

for i = 1:length(hkeys)
   k           = hkeys{i};
   [tmp,name,ext]=fileparts(k);
   dest_lbl    = img_lbl(k);
   dest_err    = img_err(k);
   dest_cnt    = img_cnt(k);
   dest_folder = fullfile('error',CLASSES{dest_lbl});
   if(~exist(dest_folder))
	mkdir(dest_folder);
   end;
   dest_name   = sprintf('%s_%d_%d_%d.jpg',name,dest_err,dest_cnt,floor(dest_err/dest_cnt*100));
   system(sprintf('cp %s %s',k,fullfile(dest_folder,dest_name))); 
   idx         = idx+1;
end;
fclose(fid);
