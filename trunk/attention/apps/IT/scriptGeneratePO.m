function [pO,thresh,sel]=scriptGeneratePO(X,Y,nFtr,doFtrSel,xSigma)
    addpath('~/utils');
    addpath('~/lgn');
    addpath('~/ulmann/code');
    addpath(genpath('~/third_party/stprtool'));
    pO=[];
    if(~doFtrSel)
        [sel,thresh]=script_ftr_sel_mi(X',Y',nFtr);thresh=repmat(thresh(:),1,length(sel));
        T = 18;
        for obj=unique(Y(:)')
            for f=1:length(sel);
                pO(f,obj)=min(0.99,max(0.01,mean(X(Y==obj,sel(f))>thresh(f,T))));
            end;
        end;  
        pO(:,end+1)=0.5;
        thresh     =thresh(:,T);
   else
       thresh=inf(size(X,2),1);
       sel   =1:size(X,2);
       pO    =zeros(size(X,2),length(unique(Y(:)')));
       for obj=unique(Y(:)')
           tY=Y; tY(Y==obj)=1; tY(Y~=obj)=-1;
           [s,th]=script_ftr_sel_mi(X',tY',max(nFtr,ceil(size(X,2)/2)));
           for f=1:length(s)
               pO(s(f),obj)=mean(X(Y==obj,s(f))>th(f));
               thresh(s(f))=min(thresh(s(f)),th(f));
           end;
       end;
       pO=max(0.5,min(0.99,pO));
   end;    
