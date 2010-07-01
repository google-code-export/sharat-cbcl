%--------------------------------------------------
%
%sharat@mit.edu
addpath(genpath('~/third_party/BNT'));
addpath(genpath('~/cbcl-model-matlab'));
addpath('~/utils');

SZ= 5; N=SZ*SZ; sigma=.01;
DELTA = 0;
NDIR  = 4;
NCLR  = 3;
NFTR  = NDIR+NCLR;

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
				 val= 0.975*(cval==l)+0.025;%(fval~=1)*(cval==N+1);
			   else
				 val= 0.975*(cval==N+1)+0.025;
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
cellSize      =  21;
RF            =  13;

%------------------------------------------------------
%get prior
or            = {};
pL            = {};
or{1}         = [1 3 1 3 1; 3 1 3 1 3; 1 3 1 3 1; 3 1 3 1 3;1 3 1 3 1]; or{1}(2,4)=3;
or{2}         = or{1};
or{3}         = or{1};


clr{1}         = [1 2 1 2 1; 2 1 2 1 2; 1 2 1 2 1; 2 1 2 1 2;1 2 1 2 1];
clr{2}         = clr{1};
clr{3}         = clr{1};

pL{1}         =  ones(SZ,SZ); pL{1}=pL{1}/sum(pL{1}(:));
pL{2}         =  ones(SZ,SZ); pL{2}=pL{2}/sum(pL{2}(:));
pL{3}         =  0.5*ones(SZ,SZ); pL{3}(2,4)=1000; pL{3}(1,4)=2;
  	             pL{3}(3,4)=2; pL{3}(2,5)=2;pL{3}(2,3)=2;
                 pL{3}=pL{3}/sum(pL{3}(:));

pF{1}         = {[0.5 0.5],[0.5 0.5],[0.5 0.5],[0.5 0.5],[0.5 0.5],[0.5 0.5],[0.5 0.5]};
pF{2}         = {[0.4 0.6],[0.4 0.6],[0.7 0.3],[0.4 0.6],[0.7 0.3],[0.4 0.6],[0.4 0.6]};
pF{3}         = {[0.4 0.6],[0.4 0.6],[0.7 0.3],[0.4 0.6],[0.7 0.3],[0.4 0.6],[0.4 0.6]};

loc           = zeros(N,3);
for input=1:3
	stim	      =  imfilter(create_color_stimulus(or{input},clr{input},NDIR,RF,cellSize),fspecial('gaussian'));
    c0            =  create_c0(rgb2gray(stim),1,1);
	gabors        =  getGabors(RF,NDIR);
	for f         =  1:NFTR
	  c0Patches{f}=  gabors(:,:,f);
	end;  
	s1            =  s_norm_filter(c0,c0Patches);s1=s1{1};
	res           =  zeros(SZ,SZ,NFTR+1);
    for f=1:NDIR
		res(:,:,f)=blkproc(s1(:,:,f),[cellSize cellSize],inline('max(x(:))'));
	end;
	for f=1:NCLR
	    res(:,:,f+NDIR)=blkproc(stim(:,:,f),[cellSize cellSize],inline('max(x(:))'));
	end;
	res=(res>0.5);%tanh((res-0.3)*3)*0.5+0.5;  
	engine  = jtree_inf_engine(bnet);
	evidence= cell(C_start+NFTR,1);
	sevidence=cell(C_start+NFTR,1);
	for f=1:NFTR
	  plane=squeeze(res(:,:,f));
	  for l=1:N
		sevidence{C_start+f}(l)=plane(l);%1./(1+exp(-(plane(l)-0.5)*2));%double(max(0,plane(l)>0.5));
	  end;
	  sevidence{C_start+f} = sevidence{C_start+f}/sum(sevidence{C_start+f}+0.0001);
	  sevidence{C_start+f}(N+1)=0.001;
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

for i=1:3
subplot(4,3,i);
    imagesc(stimImage{i});
    axis image off;
    grid on;
    p=[];   
     for f=1:NFTR
       p(f)=pF{i}{f}(1);
     end;    
subplot(5,3,3+i);
    bar(p,'r'); 
    set(gca,'YLim',[0 1]);
    set(gca,'XLim',[0.5 7.5]);
    set(gca,'XTickLabel','');
    grid on;
     
subplot(5,3,6+i);
    bar(response(1:NFTR,i),'r'); 
    set(gca,'YLim',[0 1]);
    set(gca,'XLim',[0.5 7.5]);
    set(gca,'XTickLabel','');
    grid on;

subplot(5,3,9+i);
    imagesc(reshape(pL{i},[SZ SZ]),[0 0.1]);
    grid on;
    axis off;

subplot(5,3,12+i);
    imagesc(reshape(loc(:,i),[SZ SZ]),[0 0.08]);
    grid on;
    axis off;
end;


