%---------------------------------------------------------------------------------
%
%sharat@mit.edu
%---------------------------------------------------------------------------------
%tests bottom up attention for motion
%the features are extracted using simoncelli's code for the MT model
%
function test_color
HOME=getenv('HOME')
addpath(genpath(fullfile(HOME,'third_party','MTmodel')));
addpath(genpath(fullfile(HOME,'third_party','BNT')))
%
sz   =41
padSz=20
depth=25
NFTR =11 %8 motion + 3 color
DEBUG=0
%--------------------------------
%identities of the nodes
NLOC    = 5; %5x5
O       = 1;
L       = 2;
F_start = 2;
C_start = F_start+NFTR;
%----------------------------------------------------------
%three objects. First one detects right moving objects
%               Second one is for left moving objects
%
pO = 0.5*ones(NFTR,1);

if(DEBUG)
    load('color_engine','engine')
else
    engine=buildEngine({[5 5]},eps,eps,pO);
    save('color_engine','engine')
end;    
%----------------------------------------------------------
%setup stimulus
%
dotleft=mkDots([NLOC*sz sz*NLOC depth],pi,0.5,0.05,1,-1,'exact');
dotright=mkDots([NLOC*sz sz*NLOC depth],0,0.5,0.05,1,-1,'exact');
dotup=mkDots([NLOC*sz sz*NLOC depth],pi/2,0.5,0.05,1,-1,'exact');
clrleft=mkColor([NLOC*sz sz*NLOC depth],[1 0 0]);
clrright=mkColor([NLOC*sz sz*NLOC depth],[0 1 0]);
clrup=mkColor([NLOC*sz sz*NLOC depth],[0 0 1]);

dot  =dotleft;
dot(2*sz+[1:sz],:,:)=dotup(2*sz+[1:sz],:,:);
dot(3*sz+1:end,:,:)=dotright(3*sz+1:end,:,:);

clr  =clrleft;
clr(2*sz+[1:sz],:,:,:)=clrup(2*sz+[1:sz],:,:,:);
clr(3*sz+1:end,:,:,:)=clrright(3*sz+1:end,:,:,:);
clr =modulateDots(clr,dot);
stim{1}=dot;
cstim{1}=clr;

priorF{1}=[1 0.1 0.1 0.1 0.1 0.1 0.1 0.1 0.5 0.5 0.5];
flipBook(stim{1});
flipColor(clr);

%----------------------------------------------------------
%setup stimulus
%
dotleft=mkDots([NLOC*sz sz*NLOC depth],pi,0.5,0.05,1,-1,'exact');
dotright=mkDots([NLOC*sz sz*NLOC depth],0,0.5,0.05,1,-1,'exact');
dotup=mkDots([NLOC*sz sz*NLOC depth],pi/2,0.5,0.05,1,-1,'exact');
clrleft=mkColor([NLOC*sz sz*NLOC depth],[1 0 0]);
clrright=mkColor([NLOC*sz sz*NLOC depth],[0 1 0]);
clrup=mkColor([NLOC*sz sz*NLOC depth],[0 0 1]);

dot  =dotleft;
dot(2*sz+[1:sz],:,:)=dotup(2*sz+[1:sz],:,:);
dot(3*sz+1:end,:,:)=dotright(3*sz+1:end,:,:);

clr  =clrleft;
clr(2*sz+[1:sz],:,:,:)=clrup(2*sz+[1:sz],:,:,:);
clr(3*sz+1:end,:,:,:)=clrright(3*sz+1:end,:,:,:);
clr =modulateDots(clr,dot);
stim{2}=dot;
cstim{2}=clr;

priorF{2}=[0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.1 1 0.1];
flipBook(stim{2});
flipColor(clr);


%----------------------------------------------------------
%setup stimulus
%
dotleft=mkDots([NLOC*sz sz*NLOC depth],pi,0.5,0.05,1,-1,'exact');
dotright=mkDots([NLOC*sz sz*NLOC depth],0,0.5,0.05,1,-1,'exact');
dotup=mkDots([NLOC*sz sz*NLOC depth],pi/2,0.5,0.05,1,-1,'exact');
clrleft=mkColor([NLOC*sz sz*NLOC depth],[1 0 0]);
clrright=mkColor([NLOC*sz sz*NLOC depth],[0 1 0]);
clrup=mkColor([NLOC*sz sz*NLOC depth],[0 0 1]);

dot  =dotleft;
dot(2*sz+[1:sz],:,:)=dotup(2*sz+[1:sz],:,:);
dot(3*sz+1:end,:,:)=dotright(3*sz+1:end,:,:);

clr  =clrleft;
clr(2*sz+[1:sz],:,:,:)=clrup(2*sz+[1:sz],:,:,:);
clr(3*sz+1:end,:,:,:)=clrright(3*sz+1:end,:,:,:);
clr =modulateDots(clr,dot);
stim{3}=dot;
cstim{3}=clr;

priorF{3}=[0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5 0.5];
flipBook(stim{3});
figure(1);
flipColor(clr);
keyboard;

try
for i=1:length(stim)
    res =getMTResponse(stim{i},sz,NLOC,NFTR-3);%ignore color feature
    cres=getColorResponse(cstim{i},sz,NLOC,3); %process color feature
    res =cat(4,res,cres);
    sal =zeros(NLOC,NLOC,size(res,3));
    %-------------------------------
    %enter evidence
    sevidence=cell(C_start+NFTR,1);
    evidence=cell(C_start+NFTR,1);
    for t=1:size(res,3)
        size(res)
        fprintf('Processing time:%d\n',t)
        for n=1:NFTR
            map=squeeze(res(:,:,t,n));
            %pad to make size of image first
            [mht,mwt]=size(map);
            %figure(2);subplot(4,3,n);imagesc(map>0.5,[0 1]);colorbar;colormap('gray')
            sevidence{C_start+n}=[map(:)>0.5;0.01];
            sevidence{F_start+n}=[priorF{i}(n) 1-priorF{i}(n)];
            pL                  =ones(NLOC,NLOC);
            sevidence{L}=pL(:)/sum(pL(:));
      end;
      engine=enter_evidence(engine,evidence,'soft',sevidence);
      marg  =marginal_nodes(engine,L);
      sal(:,:,t)=reshape(marg.T,[NLOC NLOC]);
      margF=[]
      for n=1:NFTR  
          marg=marginal_nodes(engine,F_start+n)
          margF(n)=marg.T(1)
      end;
      %------------------------------------------------
      %
      imgSeq(:,:,t)=stim{i}(:,:,t);
      salSeq(:,:,t)=sal(:,:,t);
      fSeq(:,t)    =margF(:);
      hdl=figure(3+i);
      subplot(5,1,1);imagesc(stim{i}(:,:,t),[0 1]);axis image off;colormap('gray')
	  subplot(5,1,2);bar(priorF{i},'facecolor','red');axis([0.5 11.5 0 1]);grid on;
      subplot(5,1,3);bar(margF,'facecolor','red');axis([0.5 11.5 0 1]);grid on;
      subplot(5,1,4);imagesc(ones(NLOC,NLOC)/(NLOC^2),[0 0.2]);axis image off;
      subplot(5,1,5);imagesc(sal(:,:,t),[0 0.2]);axis image off;
      %subplot(3,1,1);imagesc(stim{i}(:,:,t),[0 1]);axis image off;colormap('gray')
      %subplot(3,1,2);bar(margF,'facecolor','red');axis([0.5 12.5 0 1]);grid on;
      %subplot(3,1,3);imagesc(sal(:,:,t),[0 0.2]);axis image off;
      drawnow;
     end;%t        
     resultFile=sprintf('color_%03d.mat',i);
     save(resultFile,'imgSeq','salSeq','fSeq');
     clear imgSeq,fSeq,salSeq
end;
catch
    err=lasterror;
    disp('Error occured')
    keyboard;
end;

function out=getColorResponse(stim,sz,NLOC,NFTR)
    out      =zeros(NLOC,NLOC,size(stim,3)-8,NFTR);
    for c=1:3
        c
        for t=9:size(stim,3) 
            for u=t-8:t
                out(:,:,t-8,c) = out(:,:,t-8,c)+blkproc(squeeze(stim(:,:,u,c)),[sz sz],inline('sum(x(:))'));
            end;%u
            out(:,:,t-8,c)=out(:,:,t-8,c)/8/sz/sz*20;
        end;
    end;
 
%--------------------------------
%output is four dimesional
%
function out=getMTResponse(stim,sz,NLOC,NFTR) 
    pars     =shPars;
    out      =zeros(NLOC,NLOC,size(stim,3)-8,NFTR);
    for y=0:NLOC-1
        for x=0:NLOC-1
            img      =stim(y*sz+[1:sz],x*sz+[1:sz],:);
            [pop,ind]=shModel(img,pars,'mtPattern');
            dim      =ind(2,2:end);
            for j=1:size(pop,2)
                res=reshape(pop(:,j),[dim(1) dim(2) dim(3)]);
                for t=1:dim(3)
                    tmp             =res(:,:,t);
                    out(y+1,x+1,t,j)=mean(tmp(:));
                end;%t
            end;%j
        end;%x
    end;%y


function cstim=modulateDots(clr,dot)
   cstim=zeros(size(clr));
   for t=1:size(dot,3)
       for j=1:size(clr,4)
           cstim(:,:,t,j)=clr(:,:,t,j).*dot(:,:,t);
       end;           
   end;
%end function

function cstim=mkColor(sz,clr)
   cstim=zeros(sz(1),sz(2),sz(3),length(clr));
   for i=1:sz(3)
       for j=1:length(clr)
           cstim(:,:,i,j)=clr(j);
       end;
   end;       

function flipColor(cstim)
    for i=1:size(cstim,3)
        img=squeeze(cstim(:,:,i,:));
        imagesc(img);axis image off;pause(0.1)
    end;
    
function out=createStimulus(sz,padSz,depth,direction,speed,sparsity)
    [ht,wt]=size(direction);
    out=[];
    for y=1:ht
        row=[];
        for x=1:wt
            %dot=mkSin([sz sz depth],direction(y,x),0.15,0.15);
            %dot=mkBar([sz sz depth],direction(y,x),speed(y,x),sparsity(y,x));
            dot=mkDots([sz sz depth],direction(y,x),speed(y,x),sparsity(y,x),1,-1,'exact');
            dot=padarray(dot,[floor((padSz-sz)/2) floor((padSz-sz)/2)],'pre');
            dot=padarray(dot,[ceil((padSz-sz)/2)  ceil((padSz-sz)/2)],'post');
            row=cat(2,row,dot);
        end;
        out=cat(1,out,row);
    end;
%end function
