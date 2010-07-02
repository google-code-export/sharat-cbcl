%------------------------
%
nO=3;
nF=6;
EPS=1e-1;
pO=[1-2*EPS  EPS EPS;
    1-2*EPS EPS EPS ;
    EPS 1-2*EPS EPS ;
    EPS 1-2*EPS EPS ;
    EPS EPS 1-2*EPS ;
    EPS EPS 1-2*EPS ;
];
%{if(~exist('engine.mat'))
%    engine=buildEngine({r5 5]},1,0.01,pO);
%    save('engine','engine')
%else
%    engine=buildEngine({[5 5]},1,0.01,pO);
    %load('engine','engine')
%end;    
engine=buildEngine({[5 5]},2,0.01,pO);
map=zeros(5,5);
EPS=1e-2;
NFTR=6;
F_start=2;C_start=F_start+NFTR;
evidence=cell(C_start+NFTR,1);
L=5;
%set up evidence for features
pl=map;pl(1,2)=1;ev=[pl(:);EPS] ;evidence{C_start+1}=ev;%/sum(ev(:));
pl=map;pl(2,2)=1;ev=[pl(:);EPS] ;evidence{C_start+2}=ev;%/sum(ev(:));
pl=map;pl(2,2)=1;ev=[pl(:);EPS];evidence{C_start+3}=ev;%/sum(ev(:));
pl=map;pl(4,4)=1;ev=[pl(:);EPS];evidence{C_start+4}=ev;%/sum(ev(:));
pl=map;ev=[pl(:);EPS];evidence{C_start+5}=ev;%/sum(ev(:));
pl=map;ev=[pl(:);EPS];evidence{C_start+6}=ev;%/sum(ev(:));
xc=1;yc=1;sx=1;
[x,y]=meshgrid(1:5,1:5);map=exp(-((x-xc).^2+(y-yc).^2)/(2*sx*sx));
evidence{2}=map(:);%/sum(pl(:));
pO=zeros(1,3)+0.1;pO(3)=1;evidence{1}=pO/sum(pO(:));
nPlot=ceil(sqrt(C_start+NFTR));
figure(1)
engine=enter_evidence(engine,cell(C_start+NFTR,1));
for i=1:C_start+NFTR
    m=marginal_nodes(engine,i,1);
    subplot(nPlot,nPlot,i);
    if(i==1)
        bar(m.T);
    elseif(i==2)
        imagesc(reshape(m.T,[L,L]),[0 1]);
    elseif(i<C_start+1)
        bar(m.T);
    else
        imagesc(reshape(m.T(1:L^2),[L,L]),[0 1]);
    end; 
    title(sprintf('Node:%d',i));
end;    
%%%%5555555555555555555
engine=enter_evidence(engine,evidence);
figure(2)
for i=1:C_start+NFTR
    m=marginal_nodes(engine,i,1);
    subplot(nPlot,nPlot,i);
    if(i==1)
        bar(m.T);
    elseif(i==2)
        imagesc(reshape(m.T,[L,L]),[0 1]);
    elseif(i<C_start+1)
        bar(m.T);
    else
        imagesc(reshape(m.T(1:L^2),[L,L]),[0 1]);
    end; 
    title(sprintf('Node:%d',i));
end;    
