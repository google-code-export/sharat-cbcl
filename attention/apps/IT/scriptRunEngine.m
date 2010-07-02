%------------------------------------------------------
%
%sharat@mit.edu
function scriptRunEngine(engine,pO,thresh,sel,ftrHome,destHome)
addpath(genpath('~/third_party/BNT'));
jtree_inf_engine(mk_bnet(zeros(2),[1 1]));
imgHome='/cbcl/scratch04/sharat/gabriel/testing';
ftrHome=fullfile('/cbcl/scratch04/sharat/Ying',ftrHome);
destHome=fullfile('/cbcl/scratch04/sharat/Ying',destHome);
if(~exist(destHome))
  mkdir(destHome);
end;
NFTR   =length(sel);
ftrFiles=dir(fullfile(ftrHome,'*.mat'));
ftrFiles=ftrFiles(randperm(length(ftrFiles)));
for i=1:length(ftrFiles)
  try
  load(fullfile(ftrHome,ftrFiles(i).name),'ftr','img_file');
  c2=ftr{2};
  c2=c2(:,:,sel);
  if(size(c2,1)>15)
      c2=imdilate(c2,ones(3,3));
      c2=imresize(c2,[15 15],'bicubic');
  else
      c2=imresize(c2,[15 15]);
  end;
  c2=transformMap(c2,thresh-0.01);
  %----------------------
  %enter evidence
  sevidence=cell(2+2*NFTR,1);
  evidence =cell(2+2*NFTR,1);
  C_start  =2+NFTR;
  for f=1:NFTR
	plane               =c2(:,:,f);
	sevidence{C_start+f}=[plane(:);0.005];
  end;
 
  NLOC  =15;%round(sqrt(size(map,2)));
  salmap=zeros(NLOC,NLOC,5);
  for obj=1:5
    evidence{1}=obj;
	engine     =enter_evidence(engine,evidence,'soft',sevidence);
    map        =marginal_nodes(engine,[2]);map=log(map.T);
    salmap(:,:,obj)=reshape(map,[NLOC NLOC]);
  end;
  
  figure(1);imagesc(imread(fullfile(imgHome,img_file)));axis image;
  title(img_file);
  figure(2);
  for p=1:size(salmap,3)
	subplot(2,3,p);imagesc(salmap(:,:,p));colorbar;
	axis image;
  end;
  [path,name,ext] = fileparts(img_file);
  destFile=fullfile(destHome,[name '.mat']);
  save(destFile,'img_file','salmap');
  pause(1);
  catch
      err=lasterror;
    keyboard;
  end;
end;  
