%--------------------------------------------------
%
%sharat@mit.edu
addpath(genpath('third_party/BNT'));
EPS=0.05;
EPS2=0.05;
warning('off','all')

DELTA = 0;
NDIR  = 4;
NPTS  = 16;%number of points on the tuning curve
SZ=5;
N=SZ*SZ;
L = 1; F_start=1; C_start=F_start+NDIR;
dag   = zeros(C_start+NDIR);
%---------------------------
%connectivity
for i=1:NDIR
    dag(L,C_start+i)        =1;
    dag(F_start+i,C_start+i)=1;
end;

bnet = mk_bnet(dag,[N ones(1,NDIR)*2 ones(1,NDIR)*(N+1)],'discrete',[L F_start+[1:NDIR] C_start+[1:NDIR]]);
%---------------------------------------------
% define CPTs
bnet.CPD{L}=tabular_CPD(bnet,L,'CPT','unif');
for f=1:NDIR
  bnet.CPD{F_start+f}=tabular_CPD(bnet,F_start+f,'CPT','unif');
  tbl    =zeros(N,2,N+1);
  for l=1:N
	  for fval=1:2
            for cval=1:N+1
			   if(fval==1)
				 val= (1-EPS)*(cval==l)+EPS;;
			   else
				 val= (1-EPS)*(cval==N+1)+EPS;
			   end;
			   tbl(l,fval,cval)=val;%the last part is
                                    %important for bottom up
			end;
			tbl(l,fval,:)=tbl(l,fval,:)/sum(tbl(l,fval,:)); 
	  end;	   
  end;		  
  bnet.CPD{C_start+f}=tabular_CPD(bnet,C_start+f,'CPT',tbl);
end;
%-----------------------------------------------------
%generate stimulus
RF            =  25;

%We will be measuring V4 'neuron' at sx,sy
sx=4;sy=3;
%distractor position and orientation
dx=2;dy=3;dor=floor(NPTS/2)+1;

pL            = {};
%uniform attention
pL{1}         =  ones(SZ,SZ); pL{1}=pL{1}/sum(pL{1}(:));
%attention at sx,sy
pL{2}         =  ones(SZ,SZ); pL{2}(sy,sx)=10; pL{2}=pL{2}/sum(pL{2}(:));
%attention away from sx,sy
pL{3}         =  ones(SZ,SZ); pL{3}(dy,dx)=100; pL{3}=pL{3}/sum(pL{3}(:));

for l=1:length(pL)
    fprintf('Analyzing:%d of %d\n',l,length(pL))
    for input= 1:NPTS
        or       	  =  zeros(SZ); 
        or(sy,sx)     =  input;
        or(dy,dx)     =  dor;
        stim	      =  create_stimulus(or,NPTS,RF,RF);
        gabors        =  getGabors(RF,NDIR);
        res           =  zeros(SZ,SZ,NDIR);
        for f=1:NDIR
          res(:,:,f)=blkproc(stim,[RF RF],@(x) sum(sum(gabors(:,:,f).*x)));
        end;
        engine  = jtree_inf_engine(bnet);
        sevidence=cell(C_start+NDIR,1);
        evidence =cell(C_start+NDIR,1);
    	for f=1:NDIR
	      plane=squeeze(abs(res(:,:,f)));
	      %the bottom up evidence can be any non-linear function 
          %of the filter response,the best being a theshold followed
          %by a sigmoid. 
	      sevidence{C_start+f}(1:N)=tanh(max(0,plane));
	      sevidence{C_start+f}(N+1)=EPS2;
        end;  
        sevidence{L}=pL{l}(:);
        engine = enter_evidence(engine,evidence,'soft',sevidence);
        margC=marginal_nodes(engine,C_start+3); %for NDIR=4, this corresponds
                                                %to vertical features
        margF=marginal_nodes(engine,F_start+3);
        response(input,l)=margC.T((sx-1)*SZ+sy);
        fprintf('Finished %d\n',input);
    end;%input
end;%l    
plot(response);legend('uniform attn','attn at target','attn at distractor')

