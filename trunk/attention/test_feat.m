%--------------------------------------------------
%
%sharat@mit.edu
close all;clear all;
addpath(genpath('~/third_party/BNT'));
addpath(genpath('~/cbcl-model-matlab'));

L = 1; F=2; I_start=2;
SZ= 3; N=SZ*SZ; sigma=.01;
dag   = zeros(I_start+N);
DELTA = 0;
NDIR  = 4;
%---------------------------
%connectiveity
for i=1:N
    dag(L,I_start+i)=1;
    dag(F,I_start+i)=1;
end;

bnet = mk_bnet(dag,[N NDIR+1 (NDIR+1)*ones(1,N)],'discrete',[F L I_start+[1:N]]);

%---------------------------------------------
%test 
bnet.CPD{L}=tabular_CPD(bnet,L,'CPT','unif');
for c=1:N
     tbl    =zeros(N,NDIR+1,NDIR+1);
     for l=1:N
		    for oval=1:NDIR+1
			    if(l==c)
                    for cval=1:NDIR+1
            		   tbl(l,oval,cval) = (cval==oval)*0.8+0.2;
				    end;
                    tbl(l,oval,:)=tbl(l,oval,:)/sum(tbl(l,oval,:));
                else
                    for cval=1:NDIR+1
                        tbl(l,oval,cval)= (cval==(NDIR+1))*0.8+0.2;
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
RF            =  17;

%-----------------------------------------
%set up inputs
%
or{1}         =  zeros(SZ);     or{1}(3,3)=1; or{1}(1,1)=3;
or{2}         =  zeros(SZ);     or{2}(3,3)=2; or{2}(1,1)=3;
or{3}         =  zeros(SZ);     or{3}(3,3)=1; or{3}(1,1)=3;
or{4}         =  zeros(SZ);     or{4}(3,3)=2; or{4}(1,1)=3;

pF{1}         =  0.0*ones(1,NDIR+1); pF{1}(1)=1; %pF{1}(end)=0.1;
pF{2}         =  0.0*ones(1,NDIR+1); pF{2}(1)=1; %pF{2}(end)=0.1;
pF{3}         =  0.0*ones(1,NDIR+1); pF{3}(3)=1; %pF{3}(end)=0.1;
pF{4}         =  0.0*ones(1,NDIR+1); pF{4}(3)=1; %pF{4}(end)=0.1;


for input=1:4
stim	      =  imfilter(create_stimulus(or{input},NDIR,RF,cellSize),fspecial('gaussian'));
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
evidence= cell(I_start+N,1);
sevidence=cell(I_start+N,1);
bnet.CPD{F}=tabular_CPD(bnet,F,'CPT',pF{input}/sum(pF{input}));
engine  = jtree_inf_engine(bnet);

pos  =1;
for x=1:SZ
  for y=1:SZ
	column                =reshape(res(y,x,:),[NDIR+1,1]);
	sevidence{I_start+pos}=column/sum(column);
    pos =pos+1;
  end;
end;
%sevidence{F}= pF{input}/sum(pF{input});
engine = enter_evidence(engine,evidence,'soft',sevidence);


margF=marginal_nodes(engine,I_start+9);
fprintf('Finished %d\n',input);
val=margF.T(1); 
t = 0:0.01:0.5;
color={'r','b','r--','b--'};
figure(1);subplot(2,2,input);bar(margF.T);%imagesc(stim);axis image off;colormap('gray');
figure(2);hold on;plot(t/0.5*200,val*(1-exp(-t/0.1)),color{input},'lineWidth',2);hold on;
end;
hold off;
legend('P stim/P cue','NP stim/ P.cue','P.stim/NP cue','NP stim/NP cue');


