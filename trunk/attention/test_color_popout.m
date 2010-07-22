%--------------------------------------------------
%demonstrates that pop-out is independent of feature
%identity.
%sharat@mit.edu
addpath(genpath('third_party/BNT'));
warning('all','off')

SZ= 5; N=SZ*SZ; 
DELTA = 0;
NDIR  = 4;
NCLR  = 3;
NFTR  = NDIR+NCLR;
EPS=0.001;
EPS2=0.001;

L = 1; F_start=1; C_start=F_start+NFTR;
dag   = zeros(C_start+NFTR);
%---------------------------
%connectiveity
for i=1:NFTR
    dag(L,C_start+i)        =1;
    dag(F_start+i,C_start+i)=1;
end;

bnet = mk_bnet(dag,[N ones(1,NFTR)*2 ones(1,NFTR)*(N+1)],'discrete',[L F_start+[1:NFTR] C_start+[1:NFTR]]);
%---------------------------------------------
%test 
bnet.CPD{L}=tabular_CPD(bnet,L,'CPT','unif');
for f=1:NFTR
  bnet.CPD{F_start+f}=tabular_CPD(bnet,F_start+f,'CPT','unif');
  tbl    =zeros(N,2,N+1);
  for l=1:N
	  for fval=1:2
            for cval=1:N+1
			   if(fval==1)
				 val= (1-EPS)*(cval==l)+EPS;
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
RF      =  15;

%------------------------------------------------------
%get prior
or            = {};
pL            = {};
or{1}         = ones(SZ); or{1}(3,3)=3; 
or{2}         = ones(SZ); 
or{3}         = [1 3 1 3 1; 3 1 3 1 3; 1 3 1 3 1; 3 1 3 1 3;1 3 1 ...
	            3 1]; or{3}(2,4)=3;
or{4}         = or{3};

clr{1}         = 2*ones(SZ); 
clr{2}        =  2*ones(SZ); clr{2}(3,3)=1; 
clr{3}         = [1 2 1 2 1; 2 1 2 1 2; 1 2 1 2 1; 2 1 2 1 2;1 2 1 ...
	            2 1];;
clr{4}        = clr{3};
pL{1}         =  ones(SZ,SZ); pL{1}=pL{1}/sum(pL{1}(:));
pL{2}         =  ones(SZ,SZ); pL{2}=pL{2}/sum(pL{2}(:));
pL{3}         =  ones(SZ,SZ); pL{3}=pL{3}/sum(pL{3}(:));
pL{4}         =  ones(SZ,SZ); pL{4}=pL{4}/sum(pL{4}(:));

pF{1}         = {[0.5 0.5],[0.5 0.5],[0.5 0.5],[0.5 0.5],[0.5 0.5],[0.5 0.5],[0.5 0.5]};
pF{2}         = {[0.5 0.5],[0.5 0.5],[0.5 0.5],[0.5 0.5],[0.5 0.5],[0.5 0.5],[0.5 0.5]};
pF{3}         = {[0.5 0.5],[0.5 0.5],[0.5 0.5],[0.5 0.5],[0.5 0.5],[0.5 0.5],[0.5 0.5]};
pF{4}         = {[0.5 0.5],[0.5 0.5],[0.8 0.2],[0.5 0.5],[0.8 0.2],[0.5 0.5],[0.5 0.5]};

thresh=zeros(NFTR,1);
for input=1:length(or)
	stim	      =  imfilter(create_color_stimulus(or{input},clr{input},NDIR,RF,RF),fspecial('gaussian'));
	gabors        =  getGabors(RF,NDIR);
	gaussian      =  fspecial('gaussian',RF,RF/4);
	res           =  zeros(SZ,SZ,NFTR);
      for f=1:NDIR
		res(:,:,f)=blkproc(rgb2gray(stim),[RF RF],@(x) sum(sum(gabors(:,:,f).*x)));
		thresh(f)=0.8;
	end;
	for f=1:NCLR
	    res(:,:,f+NDIR)=blkproc(stim(:,:,f),[RF RF],@(x) 	sum(sum(gaussian.*x))); %average color
	    thresh(NDIR+f)=0.25; %color and orientation have different dynamic ranges
	end;
	engine  = jtree_inf_engine(bnet);
	evidence= cell(C_start+NFTR,1);
	sevidence=cell(C_start+NFTR,1);
	for f=1:NFTR
	  plane=squeeze(res(:,:,f));
 	  sevidence{C_start+f}(1:N)=double(plane(:)>=thresh(f));
	  sevidence{C_start+f}(N+1)=EPS2;
	end;
    sevidence{L}=pL{input};
    for f=1:NFTR
        sevidence{F_start+f}=pF{input}{f};
    end;        
	engine = enter_evidence(engine,evidence,'soft',sevidence);
	margL=marginal_nodes(engine,L);
	loc(:,input)      =margL.T;
	for f=1:NFTR
	  margF=marginal_nodes(engine,F_start+f);
	  response(f,input) =margF.T(1);
	end;
	stimImage{input}=stim;
	input=input+1;
	fprintf('Finished %d\n',input);
end;%ypos  

figure(2);

for i=1:length(or)
subplot(4,4,i);
    imagesc(stimImage{i});
    axis image off;
    grid on;
    p=[];   
     for f=1:NFTR
       p(f)=pF{i}{f}(1);
     end;    
subplot(5,4,4+i);
    bar(p,'r'); 
    set(gca,'YLim',[0 1]);
    set(gca,'XLim',[0.5 7.5]);
    set(gca,'XTickLabel','');
    grid on;
     
subplot(5,4,8+i);
    bar(response(1:NFTR,i),'r'); 
    set(gca,'YLim',[0 1]);
    set(gca,'XLim',[0.5 7.5]);
    set(gca,'XTickLabel','');
    grid on;

subplot(5,4,12+i);
    imagesc(reshape(pL{i},[SZ SZ]),[0 0.25]); 
    grid on;
    axis off;

subplot(5,4,16+i);
    imagesc(reshape(loc(:,i),[SZ SZ]),[0 0.1]);
    grid on;
    axis off;
end;
colormap('gray')

