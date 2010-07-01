%--------------------------------------------------
%
%sharat@mit.edu
addpath(genpath('~/third_party/BNT'));
addpath(genpath('~/cbcl-model-matlab'));

L = 1; F=2; I_start=2;
SZ= 5; N=SZ*SZ; sigma=.01;
dag   = zeros(I_start+N);
DELTA = 0;
NDIR  = 16;
%---------------------------
%connectiveity
for i=1:N
    dag(L,I_start+i)=1;
    dag(F,I_start+i)=1;
end;

bnet = mk_bnet(dag,[N NDIR+1 (NDIR+1)*ones(1,N)],'discrete',[F L I_start+[1:N]]);

%---------------------------------------------
%test 
bnet.CPD{F}=tabular_CPD(bnet,F,'CPT','unif');
bnet.CPD{L}=tabular_CPD(bnet,L,'CPT','unif');
for c=1:N
     tbl    =zeros(N,NDIR+1,NDIR+1);
     for l=1:N
		    for oval=1:NDIR+1
			    if(l==c)
                    for cval=1:NDIR+1
            		   tbl(l,oval,cval) = (cval==oval)*0.99+0.01;
				    end;
                    tbl(l,oval,:)=tbl(l,oval,:)/sum(tbl(l,oval,:));
                else
                    for cval=1:NDIR+1
                        tbl(l,oval,cval)= (cval==(NDIR+1))*0.99+0.01;
                    end;
                    tbl(l,oval,:)=tbl(l,oval,:)/sum(tbl(l,oval,:));
                end;
			end;%oval
     end;%l
     bnet.CPD{I_start+c}=tabular_CPD(bnet,I_start+c,tbl);
end;
%-----------------------------------------------------
%generate stimulus
cellSize      =  21;
RF            =  13;


for input= 1:16
or       	  =  zeros(SZ); or(3,3)=input;
stim	      =  imfilter(create_stimulus(or,NDIR,RF,cellSize),fspecial('gaussian'));
c0            =  create_c0(stim,1,1);
gabors        =  getGabors(RF,NDIR);
for f         =  1:NDIR
  c0Patches{f}=  gabors(:,:,f);
end;  
s1            =  s_norm_filter(c0,c0Patches);s1=s1{1};
res           =  0.01*ones(SZ,SZ,NDIR+1);
if(1)
for f=1:NDIR
  res(:,:,f)=blkproc(s1(:,:,f),[cellSize cellSize],inline('mean(x(:))'));
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
evidence= cell(I_start+N,1);
sevidence=cell(I_start+N,1);

pos  =1;
for x=1:SZ
  for y=1:SZ
	column                =reshape(res(y,x,:),[NDIR+1,1]);
	sevidence{I_start+pos}=column/sum(column);
    pos =pos+1;
  end;
end;
pL          = 0.4*ones(SZ);pL(3,3)=1;
sevidence{L}=pL;
engine = enter_evidence(engine,evidence,'soft',sevidence);
margF=marginal_nodes(engine,F);
response(input)=margF.T(8);
fprintf('Finished %d\n',input);
end;%input

%imagesc(stim);
for o=1:NDIR+1
    %subplot(1,NDIR+1,o);imagesc(reshape(map(:,o),[SZ,SZ]),[0 1])
end;
