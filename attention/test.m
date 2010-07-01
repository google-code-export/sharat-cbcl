%--------------------------------------------------
%
%sharat@mit.edu
addpath(genpath('~/third_party/BNT'));
addpath(genpath('~/cbcl-model-matlab'));

L = 1; O=2; C_start=2;
SZ= 5; N=SZ*SZ;sigma=.5;
dag   = zeros(C_start+N);
DELTA = 0.2;
NDIR  = 4;
%---------------------------
%connectiveity
for i=1:N
    dag(L,C_start+i)=1;
    dag(O,C_start+i)=1;
end;

bnet = mk_bnet(dag,[N NDIR+1 (NDIR+1)*ones(1,N)],'discrete',[O L C_start+1:N]);
%---------------------------------------------
%test 
pO         =ones(NDIR+1,1); 
bnet.CPD{O}=tabular_CPD(bnet,O,'CPT',pO/sum(pO));
pL 	     =zeros(N,1); pL(sub2ind([SZ SZ],1,1))=1;
bnet.CPD{L}=tabular_CPD(bnet,L,'CPT','unif');
for c=1:N
     [cy,cx]=ind2sub([SZ SZ],c);
     tbl    =zeros(N,NDIR+1,NDIR+1);
     for l=1:N
            [ly,lx]=ind2sub([SZ SZ],l);
            dist       = exp(-((cy-ly)^2+(cx-lx)^2)/(2*sigma*sigma));
		for oval=1:NDIR+1
			for cval=1:NDIR+1
				if(oval==cval)
            		   tbl(l,oval,cval) = (1-dist)*1/(NDIR+1)+dist*(1-DELTA);
				else
            		   tbl(l,oval,cval) = (1-dist)*1/(NDIR+1)+dist*DELTA;
				end;
			end;
            tbl(l,oval,:)=tbl(l,oval,:)/sum(tbl(l,oval,:));
		end;
     end;
     bnet.CPD{C_start+c}=tabular_CPD(bnet,C_start+c,tbl);
end;
%-----------------------------------------------------
%generate stimulus
or       	  =  zeros(5); 
or(2,4)=1; or(4,2)=2;
stim	      =  imfilter(create_stimulus(or),fspecial('gaussian'));
c0            =  create_c0(stim,1,1);
c0Patches     =  read_patches('c0Patches.txt');
s1            =  s_norm_filter(c0,c0Patches);
s1	        =  max(0,imresize(s1{1},[SZ SZ],'bicubic'));
s1(:,:,end+1) =  0.01;
[tmp,idx]     = max(s1,[],3);
		
engine  =  jtree_inf_engine(bnet);
evidence= cell(C_start+N,1);
sevidence=cell(C_start+N,1);
for c=1:N
 evidence{C_start+c}= idx(c);
end;
engine = enter_evidence(engine,evidence);
