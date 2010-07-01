%--------------------------------------------------
%
%sharat@mit.edu
addpath(genpath('~/third_party/BNT'));
addpath(genpath('~/cbcl-model-matlab'));

L = 1; F=2; C=3;
SZ= 5; N=SZ*SZ; sigma=.01;
dag   = zeros(C);
DELTA = 0.001;
NDIR  = 4;
%---------------------------
%connectiveity
dag(L,C)=1;
dag(F,C)=1;

bnet = mk_bnet(dag,[N NDIR+1 N*NDIR+1],'discrete',[F L C]);
loc = [];
%---------------------------------------------
%test 
bnet.CPD{F}=tabular_CPD(bnet,F,'CPT','unif');
bnet.CPD{L}=tabular_CPD(bnet,L,'CPT','unif');
tbl  =DELTA*ones(N,NDIR+1,N*NDIR+1);
for l=1:N
  for f=1:NDIR+1
	for cf=1:NDIR
	  for cl=1:N
		cidx=(cf-1)*N+cl;
	    tbl(l,f,cidx)=(1-DELTA)*(cl==l & f==cf)+DELTA;
	  end;
	end;
	tbl(l,f,end)=(1-DELTA)*(f==NDIR+1)+DELTA;
	tbl(l,f,:)  =tbl(l,f,:)/sum(tbl(l,f,:));
  end;%f
end;%l  
bnet.CPD{C}=tabular_CPD(bnet,C,'CPT',tbl);
%-----------------------------------------------------
%generate stimulus
cellSize      =  21;
RF            =  13;

%------------------------------------------------------
%get prior

input=1;
for xpos=[0 2 3 4]
  for ypos=xpos
	or       	  =  zeros(SZ); if(xpos>0) or(ypos,xpos)=1; or(1,4)=3;end;
	stim	      =  imfilter(create_stimulus(or,NDIR,RF,cellSize),fspecial('gaussian'));
	c0            =  create_c0(stim,1,1);
	gabors        =  getGabors(RF,NDIR);
	for f         =  1:NDIR
	  c0Patches{f}=  gabors(:,:,f);
	end;  
	s1            =  s_norm_filter(c0,c0Patches);s1=s1{1};
	res           =  0.5*ones(SZ,SZ,NDIR+1);
	if(1)
	  for f=1:NDIR
		res(:,:,f)=blkproc(s1(:,:,f),[cellSize cellSize],inline('max(x(:))'));
	  end;
	else
	  for f=1:NDIR
		for y=1:SZ
		  for x=1:SZ
			if(or(y,x)>0)
			  res(y,x,f)=max(0.1,exp(10*cos((f-or(y,x))*pi/NDIR)));
			end;
		  end;
		end;
	  end;
	end;  
	engine  = jtree_inf_engine(bnet);
	evidence= cell(C,1);
	sevidence=cell(C,1);

	pos        =1;
	[val,idx]  = max(res,[],3)
	for f=1:NDIR
	  pos = 1;
	  for x=1:SZ
		for y=1:SZ
		  cidx=(f-1)*N+pos;
		  sevidence{C}(cidx)=(idx(pos)==f)/(sum(idx(:)==f)+eps);
		  pos = pos+1;
		end;
	  end;
	end;
	sevidence{C}(N*NDIR+1) = 0.01;
	pL          = ones(SZ);pL(3,3)=1;
	sevidence{L}=pL;
	engine = enter_evidence(engine,evidence,'soft',sevidence);
	margF=marginal_nodes(engine,F);
	margL=marginal_nodes(engine,L);
	loc(:,input)      =margL.T;
	response(:,input) =margF.T;
	stimImage{input}=stim;
	input=input+1;
	fprintf('Finished %d\n',input);
  end;%xpos
end;%ypos  

figure(2);

for i=1:4;
subplot(3,4,i);imagesc(stimImage{i});axis image off;grid on;
subplot(3,4,4+i);bar(response(1:NDIR,i),'r'); set(gca,'YLim',[0 1]);grid on;axis off; grid on;
subplot(3,4,8+i);imagesc(reshape(loc(:,i),[SZ SZ]));grid on;axis off;
end;


