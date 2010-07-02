%---------------------------------------------------------------------------------
%
%sharat@mit.edu
%---------------------------------------------------------------------------------
%tests bottom up attention for motion
%the features are extracted using simoncelli's code for the MT model
%
function test_bu
HOME=getenv('HOME')
addpath(genpath(fullfile(HOME,'third_party','MTmodel')));
addpath(genpath(fullfile(HOME,'third_party','BNT')))
jtree_inf_engine(mk_bnet(zeros(2),[2 2]));
%
sz   =41
padSz=20
depth=51
NFTR =8
DEBUG=0
%--------------------------------
%identities of the nodes
NLOC    = 5; %5x5
O       = 1;
L       = 2;
F_start = 2;
C_start = F_start+NFTR;
%----------------------------------------------------------
%
pO    =0.5*ones(NFTR,1)
if(DEBUG)
    load('engine','engine')
else
    engine=buildEngine({[5 5]},0.01,0.01,pO);
    save('engine','engine')
end;    
%----------------------------------------------------------
%setup stimulus
%
dot   =mkDots([NLOC*sz sz*NLOC depth],0,0.5,0.05,1,-1,'exact');
insert=mkDots([sz NLOC*sz depth],pi/2,0.5,0.05,1,-1,'exact');
dot(2*sz+1:3*sz,:,:)=insert;
stim{1}=dot;
flipBook(stim{1})

dot   =mkDots([NLOC*sz sz*NLOC depth],pi/2,0.5,0.05,1,-1,'exact');
insert=mkDots([sz NLOC*sz depth],0,0.5,0.05,1,-1,'exact');
dot(2*sz+1:3*sz,:,:)=insert;
stim{2}=dot;
flipBook(stim{2})

dot   =mkDots([NLOC*sz sz*NLOC depth],pi/2,0.5,0.1,1,-1,'exact');
insert=mkDots([sz NLOC*sz depth],0,0.5,0.05,1,-1,'exact');
stim{3}=dot;
flipBook(stim{3})

try
for i=1:length(stim)
    res =getMTResponse(stim{i},sz,NLOC,NFTR);
    sal =zeros(NLOC,NLOC,size(res,3));
    %-------------------------------
    %enter evidence
    sevidence=cell(C_start+NFTR,1)
    evidence=cell(C_start+NFTR,1)
    
    for t=1:size(res,3)
        size(res)
        fprintf('Processing time:%d\n',t)
        for n=1:NFTR
            map=squeeze(res(:,:,t,n));
            %pad to make size of image first
            [mht,mwt]=size(map);
            %map      =padarray(map,[floor((iht-mht)/2) floor((iwt-mwt)/2)],'pre');
            %map      =padarray(map,[ceil((iht-mht)/2) ceil((iwt-mwt)/2)],'post');
            map=imresize(map,[NLOC NLOC],'bicubic');
            %figure(1);subplot(3,3,n);imagesc(map>0.5,[0 1]);colorbar;colormap('gray')
            sevidence{C_start+n}=[map(:)>0.5;0.001];
            sevidence{F_start+n}=[0.5 0.5];
            sevidence{L}=ones(NLOC,NLOC);
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
      hdl=figure(i+2);
      subplot(5,1,1);imagesc(stim{i}(:,:,t),[0 1]);axis image off;colormap('gray')
      subplot(5,1,2);bar(ones(size(margF))*0.5,'red');axis([0.5 8.5 0 1]);grid on;
      subplot(5,1,3);bar(margF,'facecolor','red');axis([0.5 8.5 0 1]);grid on;
      subplot(5,1,4);imagesc(ones(5,5)/25,[0 0.2]);axis image off;
      subplot(5,1,5);imagesc(sal(:,:,t));axis image off;
      drawnow;
     end;%t        
     resultFile=sprintf('bu_%03d.mat',i);
     save(resultFile,'imgSeq','salSeq','fSeq');
     clear imgSeq,fSeq,salSeq
end;
catch
    err=lasterror;
    disp('Error occured')
    keyboard;
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
