
%--------------------------------------------------
%
%sharat@mit.edu
addpath(genpath('~/third_party/BNT'));
addpath(genpath('~/cbcl-model-matlab'));

L = 1; O=2; C_start=2;
SZ= 5; N=SZ*SZ;sigma=.01;
dag   = zeros(C_start+N);
DELTA = 0;
NDIR  = 2;
DIST  = 0;

%-----------------------------------------------------
%generate stimulus
input     = [1 0 1 0 1
           0 0 0 0 0 
           1 0 1 0 1
           0 0 0 0 0
           1 0 0 0 1
           ]		
pL      = [ 1 1 1 1 1
            1 1 1 1 1
            1 1 1 1 1 
            1 1 1 1 1
            1 1 1 1 1];

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


FgO   = eye(NDIR+1);
CgFL  = zeros(N,NDIR+1,(NDIR+1)*N);
for l=1:N
    [ly,lx]=ind2sub([SZ SZ],l);
    for f=1:NDIR+1
        idx   =1;
        for ff=1:NDIR+1;
            for ll=1:N
                [lly,llx]=ind2sub([SZ SZ],ll);
                CgFL(l,f,idx)=(abs(lly-ly)<=DIST & abs(llx-lx)<=DIST & ff==f)*0.99+.01;
                idx = idx+1;
            end;
        end;
    end;
end;

%---------------------------
%connectiveity
for i=1:N
    dag(L,C_start+i)=1;
    dag(O,C_start+i)=1;
end;

bnet = mk_bnet(dag,[N NDIR+1 (NDIR+1)*ones(1,N)],'discrete',[O L C_start+1:N]);

%---------------------------------------------
%test 
for c=1:N
     [cy,cx]=ind2sub([SZ SZ],c);
     tbl    =zeros(N,(NDIR+1),NDIR+1);
     idx    =1;
     for oval=1:NDIR+1
         for l=1:N
            [ly,lx]=ind2sub([SZ SZ],l);
            dist       = exp(-((cy-ly)^2+(cx-lx)^2)/(2*sigma*sigma));
			if(l==c)
                  for cval=1:NDIR+1
            	   tbl(l,oval,cval)   = (cval==oval)*0.9+0.1;
			      end;
            else
                  for cval=1:NDIR+1
                      tbl(l,oval,cval)= mean(input(:)==cval)*0.9+0.1;
                  end;
            end;
	    end;%l
     end;%oval
     x = reshape(CgFL,[N*(NDIR+1),N*(NDIR+1)])*reshape(tbl,[N*(NDIR+1),NDIR+1]);
     x = x./repmat(sum(x,2),1,size(x,2))
     bnet.CPD{C_start+c}=tabular_CPD(bnet,C_start+c,x);
end;
bnet.CPD{O}=tabular_CPD(bnet,O,'CPT',[1 1 1]);%[1/3 1/3 1/3]);%[1 0.1 0.1]);
bnet.CPD{L}=tabular_CPD(bnet,L,'CPT','unif');
engine     = jtree_inf_engine(bnet);
evidence   = cell(C_start+N,1);
sevidence  = cell(C_start+N,1);
for c=1:N
 evidence{C_start+c}= input(c);
 %sevidence{C_start+c}=[1/3 1/3 1/3];
end;
engine= enter_evidence(engine,evidence);%,'soft',sevidence);
margO = marginal_nodes(engine,O);margO.T;
margL = marginal_nodes(engine,[L O]);
map  =margL.T;
figure(1);
for o=1:NDIR+1
    subplot(1,NDIR+1,o);imagesc(reshape(map(:,o),[SZ,SZ]),[0 0.5])
end;
margL=marginal_nodes(engine,L);
figure(2);
stim=create_stimulus(input,4,11,21);stim=imfilter(stim,fspecial('gaussian'));
subplot(1,2,1);imagesc(stim);colormap('gray');axis image off;
subplot(1,2,2);imagesc(reshape(margL.T,[SZ SZ]));axis image off;

