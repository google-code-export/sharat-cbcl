%--------------------------------------------------
%test_invariance
%shows the spatial invariance property of the 
%bayesian attention model.

%sharat@mit.edu
addpath(genpath(fullfile('third_party','BNT')));
addpath(genpath('cbcl-model-matlab'));
warning('off','all')
%PARAMETERS
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
%connectivity 
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
cellSize      =  13;
RF            =  13;

%------------------------------------------------------
%get prior

input=1;
for xpos=[0 2 3 4]
  for ypos=xpos
	or       	  =  zeros(SZ); if(xpos>0) or(ypos,xpos)=1; end;
	stim	      =  imfilter(create_stimulus(or,NDIR,RF,cellSize),fspecial('gaussian'));
	c0            =  create_c0(stim,1,1);
	gabors        =  getGabors(RF,NDIR);
	res           =  EPS2*ones(SZ,SZ,NDIR+1);
    %get bottom-up evidence for each position/feature combination
	for f=1:NDIR
		res(:,:,f)=blkproc(stim,[cellSize cellSize],@(x) sum(sum(squeeze(gabors(:,:,f)).*x)));
        res(:,:,f)=max(res(:,:,f),0);
	end;
	engine  = jtree_inf_engine(bnet);
	evidence= cell(I_start+N,1);
	sevidence=cell(I_start+N,1);
    %format bottom-up evidence
	pos  =1;
	for x=1:SZ
	  for y=1:SZ
        %the bottom-up evidence can be any linear/non-linear function of the filter outputs
        %even thresholding works.
		column                =reshape(abs(res(y,x,:)).^2,[NDIR+1,1]);
		sevidence{I_start+pos}=column/sum(column);
		pos =pos+1;
	  end;
	end;
    %location prior(uniform)
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
subplot(3,4,4+i);bar(response(1:NDIR,i),'r'); set(gca,'YLim',[0 1]);grid on;axis on;grid on;
subplot(3,4,8+i);imagesc(reshape(loc(:,i),[SZ SZ]));grid on;axis off;
end;
colormap('gray');

