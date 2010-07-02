%---------------------------------------------------------------------------------
%
%sharat@mit.edu
%---------------------------------------------------------------------------------
%tests bottom up attention for motion
%the features are extracted using simoncelli's code for the MT model
%
function test_obj
HOME=getenv('HOME')
addpath(genpath(fullfile(HOME,'third_party','MTmodel')));
addpath(genpath(fullfile(HOME,'third_party','BNT')))
jtree_inf_engine(mk_bnet(zeros(2),[2 2]));

%
NFTR =4
DEBUG=0

%--------------------------------
%identities of the nodes
NLOC    = 5; %5x5
O       = 1;
L       = 2;
F_start = 2;
C_start = F_start+NFTR;
N       = NLOC*NLOC;
%----------------------------------------------------------
%three objects. First one detects right moving objects
%               Second one is for left moving objects
%
pO    = [0.9 0.9 0.1 0.1;
         0.1 0.9 0.9 0.1;
         0.1 0.1 0.9 0.9;
         0.01 0.01 0.01 0.01]';
engine=buildEngine({[5 5]},0.1,0.01,pO);
%----------------------------------------------------------
%setup stimulus
map=zeros(NLOC,NLOC,4);map(3,3,1)=1;map(1:2,2,2)=1;map(1,1,4)=1;m{1}=map;
map=zeros(NLOC,NLOC,4);map(2,2,3)=1;m{2}=map;
map=zeros(NLOC,NLOC,4);map(2,2,4)=1;m{3}=map;
map=zeros(NLOC,NLOC,4);map(3,3,1)=1;;m{4}=map;

for i=1:length(m)
    %-------------------------------
    %enter evidence
    sevidence=cell(C_start+NFTR,1)
    evidence=cell(C_start+NFTR,1)
    
    for t=1:size(m{i},3)
	        tmp=m{i}(:,:,t);
            sevidence{C_start+t}=[tmp(:)*100;0.1];
            sevidence{L}=ones(NLOC,NLOC)/(NLOC*NLOC);
    end;
    engine=enter_evidence(engine,evidence,'soft',sevidence);
    marg  =marginal_nodes(engine,L);
    sal   =reshape(marg.T,[NLOC NLOC]);
    margF=[];margO=[];
    for n=1:NFTR  
         marg=marginal_nodes(engine,F_start+n)
         margF(n)=marg.T(1)
	end;
	marg=marginal_nodes(engine,O);
	margO=marg.T;
	keyboard;
 end;


