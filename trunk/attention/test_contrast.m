%--------------------------------------------------
%
%sharat@mit.edu
addpath(genpath('~/third_party/BNT'));
addpath(genpath('~/cbcl-model-matlab'));

SZ= 5; N=SZ*SZ; sigma=.01;
DELTA = 0;
NDIR  = 1;
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
  tbl    =0.01*ones(N,2,N+1);
  for l=1:N
	  for fval=1:2
            for cval=1:N
			   if(fval==1)
				 tbl(l,fval,cval)   =0.99*(cval==l)+0.01;
				 tbl(l,fval,N+1)    =0.01;
				 %tbl(l,fval,cval+N)= 0.01;
			   else
				 tbl(l,fval,cval)  = 0.01;
				 tbl(l,fval,N+1)   = 0.99;
				 %tbl(l,fval,cval+N)= 0.99;
			   end;
			end;
			tbl(l,fval,:)=tbl(l,fval,:)/sum(tbl(l,fval,:)); 
	  end;	   
  end;		  
 bnet.CPD{C_start+f}=tabular_CPD(bnet,C_start+f,'CPT',tbl);
end;
%-----------------------------------------------------
%generate stimulus
cellSize      =  21;
RF            =  15;

%------------------------------------------------------
%get prior
or            = {};
pL            = {};
or{1}         =  zeros(SZ); or{1}(3,2)=1; or{1}(3,5)=1;
or{2}         =  zeros(SZ); or{2}(2,2)=1; 
or{3}         =  or{2};

pL{1}         =  ones(SZ,SZ); pL{1}(3,3)=5; %pL{1}=pL{1}/sum(pL{1}(:));
pL{2}         =  ones(SZ,SZ); pL{2}=pL{2}/sum(pL{2}(:));
pL{3}         =  ones(SZ,SZ); pL{3}=pL{3}/sum(pL{3}(:));

pF{1}         = {[0.8 0.2],[0.5 0.5],[0.5 0.5],[0.5 0.5]};
pF{2}         = {[0.2 0.8],[0.2 0.8],[0.8 0.2],[0.2 0.8]};
pF{3}         = {[0.8 0.2],[0.2 0.8],[0.2 0.8],[0.2 0.8]};

CONTRAST=logspace(-2,0,10);
for input=1
     if(0)
     stim	      = imfilter(create_stimulus([0 0 0 0 0;...
			                                  0 1 1 1 0;...
											  0 1 1 1 0;...
										      0 1 1 1 0;...
											  0 0 0 0 0],...
											  NDIR,15,cellSize),fspecial('gaussian'));
	  else										
		stim=imfilter(create_stimulus([1],NDIR,105,cellSize*SZ),fspecial('gaussian'));
		load stim stim;
	  end;
	  for c=1:length(CONTRAST)
	  mx          = max(stim(:));
	  mn          = min(stim(:));
	  stim        = (stim-mn)/(mx-mn+eps)*CONTRAST(c);
	  c0            =  create_c0(stim,1,1);
	  gabors        =  getGabors(RF,NDIR);
	  clear s1;
	  for f         =  1:NDIR
		s1(:,:,f)                 = abs(conv2(stim,squeeze(gabors(:,:,f)),'same'));
		s1(1:ceil(RF/2),:,f)      = 0;
		s1(end-ceil(RF/2):end,:,f)= 0;
		s1(:,1:ceil(RF/2),f)      = 0;
		s1(:,end-ceil(RF/2):end,f)= 0;
	  end;
	  s1             = tanh(max(s1,0));
	  figure(100);imagesc(s1(:,:,1));pause;figure(2);
	  %subplot(1,5,1);imagesc(stim,[0 1]);colormap('gray');
	  %for j=1:4
	  %	subplot(1,5,j+1);imagesc(s1(:,:,j),[0 1]);colormap('gray');
	  %end;
	  %pause;
	  %continue;
	  res           =  zeros(SZ,SZ,NDIR);
	  for f=1:NDIR
		res(:,:,f)=blkproc(s1(:,:,f),[cellSize cellSize],inline('mean(x(:))'));
	  end;
	  mask=zeros(5,5,NDIR);mask(2:4,2:4,:)=1;
	  res =res.*mask;
	  engine  = jtree_inf_engine(bnet);
	  evidence= cell(C_start+NDIR,1);
	  sevidence=cell(C_start+NDIR,1);
	  for f=1:NDIR
		plane=squeeze(res(:,:,f));
		for l=1:N
		  sevidence{C_start+f}(l)=plane(l);%double(max(0,plane(l)>0.9));
		end;
		t(f,c,input)  =  (plane(13));
		sevidence{C_start+f}(N+1)=0.01;
	  end;
	  sevidence{L}=pL{input};
	  for f=1:NDIR
        sevidence{F_start+f}=pF{input}{f};
	  end;        
	  engine = enter_evidence(engine,evidence,'soft',sevidence);
	  margL=marginal_nodes(engine,L);
	  loc(:,c,input)      =margL.T(:);
	  for f=1:NDIR
		margF=marginal_nodes(engine,C_start+f);
		response(f,c,input) =margF.T(13);
	  end;
	  subplot(2,5,c);bar(1:26,margF.T);set(gca,'YLim',[0 1]);%imagesc(reshape(margF.T(1:N),[SZ SZ]),[0 1]);
	  stimImage{c,input}=stim;
	  fprintf('Finished %d,%d\n',input,c);
	end;%contrast
end ;%stim	

if(0)
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
    imagesc(reshape(pL{i},[SZ SZ]),[0 0.1]);
    grid on;
    axis off;

subplot(5,3,12+i);
    imagesc(reshape(loc(:,i),[SZ SZ]),[0 0.75]);
    grid on;
    axis off;
end;
end;

