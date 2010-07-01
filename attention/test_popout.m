%--------------------------------------------------
%
%sharat@mit.edu
addpath(genpath('~/third_party/BNT'));
addpath(genpath('~/cbcl-model-matlab'));
EPS=0.01;
EPS2=0.01;

SZ= 5; N=SZ*SZ; sigma=.01;
DELTA = 0;
NDIR  = 4;
L = 1; F_start=1; C_start=F_start+NDIR;
dag   = zeros(C_start+NDIR);
%---------------------------
%connectiveity
for i=1:NDIR
    dag(L,C_start+i)        =1;
    dag(F_start+i,C_start+i)=1;
end;

bnet = mk_bnet(dag,[N ones(1,NDIR)*2 ones(1,NDIR)*(N+1)],'discrete',[L F_start+[1:NDIR] C_start+[1:NDIR]]);
%---------------------------------------------
%test 
bnet.CPD{L}=tabular_CPD(bnet,L,'CPT','unif');
for f=1:NDIR
  bnet.CPD{F_start+f}=tabular_CPD(bnet,F_start+f,'CPT','unif');
  tbl    =zeros(N,2,N+1);
  for l=1:N
	  for fval=1:2
            for cval=1:N+1
			   if(fval==1)
				 val= (1-EPS)*(cval==l)+EPS;%(fval~=1)*(cval==N+1);
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
cellSize      =  21;
RF            =  13;

%------------------------------------------------------
%get prior
or            = {};
pL            = {};
or{1}         =  zeros(SZ); or{1}(3,3)=3; or{1}(1,1)=1; 
or{2}         =  zeros(SZ); or{2}(3,3)=3; or{2}(1,1)=1; or{2}(5,5)=1; or{2}(1,5)=1;or{2}(5,1)=1;
or{3}         =  ones(SZ);or{3}(3,3)=3;

pL{1}         =  ones(SZ,SZ); pL{1}=pL{1}/sum(pL{1}(:));
pL{2}         =  ones(SZ,SZ); pL{2}=pL{2}/sum(pL{2}(:));
pL{3}         =  ones(SZ,SZ); pL{3}=pL{3}/sum(pL{3}(:));

pF{1}         = {[0.5 0.5],[0.5 0.5],[0.5 0.5],[0.5 0.5]};
pF{2}         = {[0.5 0.5],[0.5 0.5],[0.5 0.5],[0.5 0.5]};
pF{3}         = {[0.5 0.5],[0.5 0.5],[0.5 0.5],[0.5 0.5]};


for input=1:3
	stim	      =  imfilter(create_stimulus(or{input},NDIR,RF,cellSize),fspecial('gaussian'));

    c0            =  create_c0(stim,1,1);
	gabors        =  getGabors(RF,NDIR);
    mn            =  min(gabors(:));
    mx            =  max(gabors(:));
	for f         =  1:NDIR
	  c0Patches{f}=  gabors(:,:,f);
	end;  
	s1            =  s_norm_filter(c0,c0Patches);s1=s1{1};
	res           =  zeros(SZ,SZ,NDIR+1);
    for f=1:NDIR
		res(:,:,f)=blkproc(s1(:,:,f),[cellSize cellSize],inline('max(x(:))'));
    end;
	engine  = jtree_inf_engine(bnet);
	evidence= cell(C_start+NDIR,1);
	sevidence=cell(C_start+NDIR,1);
	for f=1:NDIR
	  plane=squeeze(res(:,:,f));
	  for l=1:N
		sevidence{C_start+f}(l)=double(max(0,plane(l)>0.9));
	  end;
	  sevidence{C_start+f} = sevidence{C_start+f}/sum(sevidence{C_start+f}+0.0001);
	  sevidence{C_start+f}(N+1)=EPS2;
	end;
    sevidence{L}=pL{input};
    for f=1:NDIR
        sevidence{F_start+f}=pF{input}{f};
    end;        
	engine = enter_evidence(engine,evidence,'soft',sevidence);
	margL=marginal_nodes(engine,L);
	loc(:,input)      =margL.T;
	for f=1:NDIR
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
     for f=1:NDIR
       p(f)=pF{i}{f}(1);
     end;    
subplot(5,3,3+i);
    bar(p,'r'); 
    set(gca,'YLim',[0 1]);
    set(gca,'XLim',[0.5 4.5]);
    set(gca,'XTickLabel','');
    grid on;
     
subplot(5,3,6+i);
    bar(response(1:NDIR,i),'r'); 
    set(gca,'YLim',[0 1]);
    set(gca,'XLim',[0.5 4.5]);
    set(gca,'XTickLabel','');
    grid on;

subplot(5,3,9+i);
    imagesc(reshape(pL{i},[SZ SZ]),[0 .4]);
    grid on;
    axis off;

subplot(5,3,12+i);
    imagesc(reshape(loc(:,i),[SZ SZ]),[0 0.4]);
    grid on;
    axis off;
end;

colormap('gray');
set(gcf,'color','white');

