
%--------------------------------------------------
%
%sharat@mit.edu
addpath(genpath('~/third_party/BNT'));
addpath(genpath('~/cbcl-model-matlab'));

L = 1; O=2; I_start=2;
SZ= 5; N=SZ*SZ;sigma=.01;
dag   = zeros(I_start+N);
DELTA = 1e-3;
NDIR  = 4;
DIST  = 0;

%-----------------------------------------------------
%generate stimulus
%pL      = [ 1 1 1 1 1
%            1 1 1 1 1
%            1 1 1 1 1 
%            1 1 1 1 1
%            1 1 1 1 1];

input=[1 5 5 5 5
       5 5 4 5 5
	   5 5 4 5 5
	   5 5 5 5 5
	   5 5 5 5 5];
%input=[5 1
%       1 2];
%---------------------------
%connectiveity
for i=1:N
    dag(L,I_start+i)=1;
    dag(O,I_start+i)=1;
end;

bnet = mk_bnet(dag,[N NDIR+1 (NDIR+1)*ones(1,N)],'discrete',[O L I_start+1:N]);

%---------------------------------------------
%test 
for c=1:N
     tbl    =DELTA*ones(N,(NDIR+1),NDIR+1);
     for l=1:N
	   for oval=1:NDIR
		    for ival=1:NDIR+1
			  if(l==c & oval==ival)
				tbl(l,oval,ival)=1;
			  elseif(l~=c)
				tbl(l,oval,ival)=mean(ival==input(:));
			  end;
			end;%ival
	   end;%oval
	   tbl(l,NDIR+1,:)=[zeros(1,NDIR),1];  
	 end;%l
     bnet.CPD{I_start+c}=tabular_CPD(bnet,I_start+c,tbl);
end;
bnet.CPD{O}=tabular_CPD(bnet,O,'CPT','unif');
bnet.CPD{L}=tabular_CPD(bnet,L,'CPT','unif');
engine     = jtree_inf_engine(bnet);
evidence   = cell(I_start+N,1);
sevidence  = cell(I_start+N,1);
for c=1:N
 evidence{I_start+c}= input(c);
end;
engine= enter_evidence(engine,evidence);%,'soft',sevidence);
margO = marginal_nodes(engine,O);margO.T;
margL = marginal_nodes(engine,[L O]);
map  =margL.T;
figure(1);

for o=1:NDIR+1
    subplot(1,NDIR+1,o);imagesc(reshape(map(:,o),[SZ,SZ]),[0 1]);axis off image;
end;
margL=marginal_nodes(engine,L);
margO=marginal_nodes(engine,O);margO.T

figure(2);
imagesc(reshape(margL.T,[SZ SZ]));axis image off;

