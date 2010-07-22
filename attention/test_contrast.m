%--------------------------------------------------
%
%sharat@mit.edu
addpath(genpath('third_party/BNT'));
EPS=0.001;
EPS2=0.01;
warning('off','all')

DELTA = 0;
NDIR  = 4;
SZ=9;
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
%------------------------------------------------------
%uniform prior
pL{1}         =  ones(SZ,SZ); pL{1}=pL{1}/sum(pL{1}(:));
%attention smaller than stimulus
pL{2}         =  ones(SZ,SZ); pL{2}(ceil(SZ/2),ceil(SZ/2))=10;pL{2}=pL{2}/sum(pL{2}(:));
%attention larger than stimulus
pL{3}         =  ones(SZ,SZ); pL{3}(3:SZ-2,3:SZ-2)=10;pL{3}=pL{3}/sum(pL{3}(:));
response=[];

CONTRAST=logspace(-3,0,16);
for input=1:length(pL)
    figure(1);
    for c=1:length(CONTRAST)
        stim=create_stimulus([1],NDIR,ceil(2.5*RF),RF*SZ);
        mx          = max(stim(:));
        mn          = min(stim(:));
        stim        = (stim-mn)/(mx-mn+eps)*CONTRAST(c);
        gabors      =  getGabors(RF,NDIR);
        res         =  zeros(SZ,SZ,NDIR);
        for f=1:NDIR
          plane=gabors(:,:,f);
          res(:,:,f)=blkproc(stim,[RF RF],@(x) sum(sum(gabors(:,:,f).*x)));
          %subplot(1,NDIR,f);imagesc(res(:,:,f),[0 1]);colorbar;
        end;
        engine  = jtree_inf_engine(bnet);
        sevidence=cell(C_start+NDIR,1);
        evidence =cell(C_start+NDIR,1);
        for f=1:NDIR
        plane=squeeze(abs(res(:,:,f)));
        %the bottom up evidence can be any non-linear function 
        %of the filter response,the best being a theshold followed
        %by a sigmoid. 
        sevidence{C_start+f}(1:N)=tanh(max(plane,0));
        sevidence{C_start+f}(N+1)=EPS2;
        end;  
        sevidence{L}=pL{input}(:);
        engine = enter_evidence(engine,evidence,'soft',sevidence);
        margC=marginal_nodes(engine,C_start+1); %for NDIR=4, this corresponds
                                            %to vertical features
        response(c,input)=margC.T((ceil(SZ/2)-1)*SZ+ceil(SZ/2));
        fprintf('Finished %d\n',c);
    end;%c
end;%input    
plot(response);
legend('uniform','attn-small','attn-large')
