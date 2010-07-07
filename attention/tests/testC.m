
%--------------------------------------------------
%
%sharat@mit.edu
addpath(genpath('~/third_party/BNT'));
addpath(genpath('~/cbcl-model-matlab'));

C=  1; I_start=1;
SZ= 3; N=SZ*SZ;
dag   = zeros(I_start+N);
DELTA = 1e-9;
NDIR  = 2;
%---------------------------
%connectiveity
for i=1:N
    dag(C,I_start+i)=1;
end;

bnet = mk_bnet(dag,[N*NDIR+1 (NDIR+1)*ones(1,N)],'discrete',[C I_start+1:N]);

%test 
bnet.CPD{C}=tabular_CPD(bnet,C,'CPT','unif');
for i=1:N
     tbl    =DELTA*ones((NDIR*N+1),NDIR+1);
     for l=1:N
        for cval=1:NDIR
            for ival=1:NDIR
                if(l==i)
				    tbl((cval-1)*N+l,ival)=(1-DELTA)*(ival==cval)+(ival~=cval)*DELTA;
                else
 				    tbl((cval-1)*N+l,ival)=(1-DELTA)*(ival==(NDIR+1))+(ival~=(NDIR+1))*DELTA;
                end;
			end;
			tbl((cval-1)*N+l,:)=tbl((cval-1)*N+l,:)/sum(tbl((cval-1)*N+l,:));  
		end;  
	  end;
	  for ival=1:NDIR+1
		   tbl(NDIR*N+1,ival)==(ival==(NDIR+1))*(1-DELTA)*(ival~=(NDIR+1))*DELTA;
	  end;
  	  tbl(NDIR*N+1,ival) =tbl(NDIR*N+1,ival)/sum(tbl(NDIR*N+1,ival));
	  bnet.CPD{I_start+i}=tabular_CPD(bnet,I_start+i,tbl);
end;
%-----------------------------------------------------
%generate stimulus
idx     = [1 3 3
           3 1 2
		   3 3 3];
engine  =  jtree_inf_engine(bnet);
evidence= cell(I_start+N,1);
for i=1:N
  evidence{I_start+i}= idx(i);
end;
engine = enter_evidence(engine,evidence);
margC  = marginal_nodes(engine,C);
map    =reshape(margC.T(1:N*NDIR),[N,NDIR]);
for  i=1:NDIR
  subplot(1,NDIR,i);imagesc(reshape(map(:,i),[SZ SZ]),[0 1]);
end;
fprintf('NULL:%f\n',margC.T(end));
