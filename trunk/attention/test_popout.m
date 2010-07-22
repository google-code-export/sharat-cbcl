%--------------------------------------------------
%Demonstrates the pop-out effect, an emergent property
%of the model.
%sharat@mit.edu
addpath(genpath('third_party/BNT'));
EPS=0.001;
EPS2=0.001;
warning('off','all')
SZ= 5; N=SZ*SZ; 
DELTA = 0;
NDIR  = 4;
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
	stim	      =  imfilter(create_stimulus(or{input},NDIR,RF,RF),fspecial('gaussian'));
	gabors        =  getGabors(RF,NDIR);
	res           =  zeros(SZ,SZ,NDIR+1);
	for f=1:NDIR
		res(:,:,f)=blkproc(stim,[RF RF],@(x) sum(sum(x.*gabors(:,:,f))));
	        res(:,:,f)=abs(res(:,:,f));
    	end;
	engine  = jtree_inf_engine(bnet);
	evidence= cell(C_start+NDIR,1);
	sevidence=cell(C_start+NDIR,1);
	for f=1:NDIR
	  plane=squeeze(res(:,:,f));
	   %the bottom up evidence can be any non-linear function 
       %of the filter response,the best being a theshold followed
       %by a sigmoid. here 0.5 is the detection threshold.
	   sevidence{C_start+f}(1:N)=double(max(plane(:),0));
	   sevidence{C_start+f}(N+1)=EPS2;
	end;
    sevidence{L}=pL{input};
    for f=1:NDIR
        sevidence{F_start+f}=pF{input}{f};
    end;        
	%if you are using belief propagation engine(checked out from here), then replace
    	%engine=enter_evidence(engine,sevidence);
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

