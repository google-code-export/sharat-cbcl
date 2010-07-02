function learnBNET
addpath(genpath('~/third_party/BNT'));
addpath('~/utils');
%--------------------------------------
%create bnet
SZ      = 3;
NLOC    = SZ*SZ;
NFTR    = 4; %+1 NULL 
RF      = 49;           %5x5 receptive field

L       = 1;            % location variable
F       = 2;            % feature variable
S_start = 2;            % simple cells
I_start = S_start+NLOC; % image pixels

dag     = zeros(1+1+SZ*SZ+NLOC*RF);
%simple cells
for s=1:NLOC
  dag(L,S_start+s)=1;
  dag(F,S_start+s)=1;
  %pixels
  for i=1:RF
	dag(S_start+s,I_start+(s-1)*RF+i)=1;
  end;
end;

%-------------------------
%define equiv_classes
eclass   = ones(1,size(dag,1));
eclass(L)= L;
eclass(F)= F;
eclass(S_start+[1:NLOC])=S_start+[1:NLOC];
for s=1:NLOC
  for i=1:RF
	eclass(I_start+(s-1)*RF+i)=I_start+i;
  end;
end;
bnet= mk_bnet(dag,[NLOC (NFTR+1) ones(1,NLOC)*(NFTR+1) ones(1,RF*NLOC)*3],'equiv_class',eclass,...
	          'discrete',[1:size(dag,1)],'observed',I_start+[1:RF*NLOC]);

%------------
%L
bnet.CPD{L}=tabular_CPD(bnet,bnet.rep_of_eclass(L),'CPT','unif');
%-----------
%F
tbl        = 0.1/NFTR*ones(1,NFTR+1); tbl(end)=0.9; tbl=tbl/sum(tbl(:));
bnet.CPD{F}= tabular_CPD(bnet,bnet.rep_of_eclass(F),'CPT',tbl,'adjustable',0);
%----------------
%S
for s=1:NLOC
  tbl  =zeros(NLOC,NFTR+1,NFTR+1);
  for l=1:NLOC
	for f=1:NFTR+1
	  if(s==l)
		for sval=1:NFTR+1
		  tbl(l,f,sval)=(sval==f)*0.9+0.1*(sval~=f);
		end;
	  else
		for sval=1:NFTR+1
		  tbl(l,f,sval)=(sval==(NFTR+1))*0.9+0.1*(sval~=(NFTR+1));
		end;
	  end;
	  tbl(l,f,:)=tbl(l,f,:)/sum(tbl(l,f,:));
	end;%f
  end %l
  bnet.CPD{S_start+s}=tabular_CPD(bnet,bnet.rep_of_eclass(S_start+s),'CPT',tbl,'adjustable',0);
end;

for i=1:RF
 bnet.CPD{I_start+i}=tabular_CPD(bnet,bnet.rep_of_eclass(I_start+i),'CPT','rnd');
end;

%--------------------
%image database
sIdx   =1;
samples={};
imgHome='/cbcl/scratch01/sharat/databases/AnimalAude/TrainImages';
for imgPath={'Animals','Non-Animals'}
  imgDir =dir(fullfile(imgHome,char(imgPath),'*.pgm'));
  imgDir =imgDir(randperm(length(imgDir)));
  for i=1:min(30,length(imgDir))
	fprintf('reading image:%d of %d\n',i,length(imgDir));
	img          =imread(fullfile(imgHome,char(imgPath),imgDir(i).name));
	img          =preProcessImage(img);
	cimg         =im2col(img,[15 15],'distinct');
	cimg(cimg==0)=3;
	for col=1:size(cimg,2)
	  blk  =reshape(cimg(:,col),[15 15]);
	  uIdx =0;
	  for x=1:4:9
		for y=1:4:9
		  patch=blk(y:y+6,x:x+6); patch=patch(:);
		  for iIdx=1:length(patch)
			samples{I_start+uIdx*RF+iIdx,sIdx}=patch(iIdx);
		  end;
		  uIdx = uIdx+1;
		end;%y
	  end;%x
	  fprintf('uIdx==%d',uIdx);
	  assert(uIdx==NLOC);
	  fprintf('Sample:%d\n',sIdx);
	  sIdx = sIdx+1;
	end;%col
  end;%i
end;%img
engine               =jtree_inf_engine(bnet);
[bnet,lltrace,engine]=learn_params_em(engine,samples);
keyboard;

