%--------------------------------------------------
%
%sharat@mit.edu
addpath(genpath('~/third_party/BNT'));
addpath(genpath('~/cbcl-model-matlab'));

L = 1; F=2; I_start=2;
SZ= 5; N=SZ*SZ; sigma=.01;
dag   = zeros(I_start+N);
DELTA = 0;
NDIR  = 4;
EPS=0.01;
EPS2=0.01;

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
            		   tbl(l,oval,cval) = (cval==oval)*(1-EPS)+EPS;
				    end;
                    tbl(l,oval,:)=tbl(l,oval,:)/sum(tbl(l,oval,:));
                else
                    for cval=1:NDIR+1
                        tbl(l,oval,cval)= (cval==(NDIR+1))*(1-EPS)+EPS;
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
RF            =  15;

%-----------------------------------------
%set up inputs
%
or{1}         =  zeros(SZ); or{1}(3,3)=1;
or{2}         =  zeros(SZ); or{2}(3,3)=1; or{2}(2,2)=3;
or{3}         =  or{2};

pL{1}         =  ones(SZ,SZ);
pL{2}         =  ones(SZ,SZ);
pL{3}         =  0.01*ones(SZ,SZ); pL{3}(3,3)=1; pL{3}=pL{3}/sum(pL{3}(:));

for input=1:3
stim	      =  imfilter(create_stimulus(or{input},NDIR,RF,cellSize),fspecial('gaussian'));
c0            =  create_c0(stim,1,1);
gabors        =  getGabors(RF,NDIR);
for f         =  1:NDIR
  c0Patches{f}=  gabors(:,:,f);
end;  
s1            =  s_norm_filter(c0,c0Patches);s1=s1{1};
res           =  EPS2*ones(SZ,SZ,NDIR+1);
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
	column                =reshape(res(y,x,:),[NDIR+1,1]).^2;
	sevidence{I_start+pos}=column/sum(column);
    pos =pos+1;
  end;
end;
sevidence{L}= pL{input};
engine = enter_evidence(engine,evidence,'soft',sevidence);


margF=marginal_nodes(engine,F);
val  =margF.T(1);
fprintf('Finished %d\n',input);

figure(1);
subplot(3,3,input);imagesc(stim);axis image off;title('Stimulus');
subplot(3,3,input+3);imagesc(reshape(pL{input},[SZ SZ]),[0 1]);axis image off;title('Spatial attention');
subplot(3,3,input+6);bar(margF.T(1:NDIR),'r');set(gca,'YLim',[0 1]);axis off;title('Feature');
colormap('gray');color=('rgb');
figure(2);
t = 0:0.01:1;
plot(t,val*(1-exp(-t/0.1)),color(input),'lineWidth',2);hold on;
end;
legend('Isolated','Crowding','Attended');


