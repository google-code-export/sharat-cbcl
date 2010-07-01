%--------------------------------------------------
%
%sharat@mit.edu
addpath(genpath('~/third_party/BNT'));
addpath(genpath('~/cbcl-model-matlab'));

L = 1; O=2; C=3;
SZ= 5; N=SZ*SZ;sigma=.01;
dag   = zeros(C);
DELTA = 0;
NDIR  = 2;
DIST  = 0;

input    = [3 3 3 3 3
           3 3 3 3 3 
           3 3 3 3 3
           3 3 1 3 3
           3 3 1 3 2
           ]		
%---------------------------
%connectiveity
for i=1:N
    dag(L,C)=1;
    dag(O,C)=1;
end;
bnet = mk_bnet(dag,[N NDIR+1 (NDIR+1)*N],'discrete',[O L C]);
tbl  =[];
for l=1:N
  for o=1:NDIR
	for co=1:NDIR+1
	  for cl=1:N
		if(cl==l);
		  tbl(l,o,(co-1)*N+cl)=(co==o);
		else
		  tbl(l,o,(co-1)*N+cl)= mean(input(:)==co)/N;
		end;
	  end;%cl
	end;%co
  end;%o
  tbl(l,o,:)       =tbl(l,o,:)/sum(tbl(l,o,:));
end;%l

bnet.CPD{C}=tabular_CPD(bnet,C,'CPT',tbl);
%---------------------------------------------
%test 
%-----------------------------------------------------
%generate stimulus
pL      = [ 1 1 1 1 1
            1 1 1 1 1
            1 1 1 1 1 
            1 1 1 1 1
            1 1 1 1 1];
for o=1:NDIR+1
  pO(o)=mean(input(:)==o);
end;  

bnet.CPD{O}=tabular_CPD(bnet,O,'CPT',pO);
bnet.CPD{L}=tabular_CPD(bnet,L,'CPT',pL);
engine     = jtree_inf_engine(bnet);
evidence   = cell(C,1);
sevidence  = cell(C,1);
idx        = 1;
sevidence{C}=[];
for o=1:NDIR+1
  for l=1:N
	sevidence{C}(idx)=(input(l)==o);
	idx = idx+1;
  end;
end;
engine= enter_evidence(engine,evidence,'soft',sevidence);
margO = marginal_nodes(engine,O);margO.T
margL = marginal_nodes(engine,[L O]);
margC = marginal_nodes(engine,[C]);

map   = margL.T
figure(1);
for o=1:NDIR
    subplot(1,NDIR,o);imagesc(reshape(map(:,o),[SZ,SZ]))
end;
margL=marginal_nodes(engine,L);
figure(2);
imagesc(reshape(margL.T,[SZ SZ]));colorbar;
