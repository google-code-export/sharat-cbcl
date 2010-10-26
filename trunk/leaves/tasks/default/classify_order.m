function t=classify_order(varargin)
    t=struct;
    t.start=@start_classify;
    t.item=@item_classify;
    t.combine=@combine_classify;

%-----------------------------------------------
function a=start_classify(p,a,input)
  disp('Start classify')
  %input X,y,catid,cat,name
  fnames=fieldnames(input);
  for i=1:length(fnames)
      a.(fnames{i})=input.(fnames{i});
  end;
  a.y=a.orderid;
  %find valid categories
  valid=ones(1,length(a.y));
  [n,x]=hist(a.y,unique(a.y(:)));
  disp('Hist')
  for i=1:length(n)
      if(n(i)<p.minCount)
        valid(a.y==x(i))=0;        
      end;
  end;    
  %filter 
  fnames=fieldnames(a);
  for i=1:length(fnames)
      if(length(a.(fnames{i}))==length(valid))
          a.(fnames{i})=a.(fnames{i})(:,find(valid));
      end;
  end;    
  %create splits
  [uclass,ui,uj]=unique(a.orderid);
  a.count=p.splits*length(uclass);
  a.batchSize=1;
  a.split=[];
  a.label=[];
  idx=1;
  for s=1:p.splits
      for u=1:length(uclass)
          a.split(idx)=s;
          a.label(idx)=uclass(u);
          a.category(idx)=a.order(ui(u));
          idx=idx+1;
      end;
  end;    
  try
  [tstSet,trnSet]=split_data(a.y(:),p.splits);
  catch
  err=lasterror;
  keyboard;
  end;
  a.tstSet=tstSet;
  a.trnSet=trnSet;

%-----------------------------------------------
function r=item_classify(p,a,input)
    thisLabel=a.label(a.itemNo);
    thisSplit=a.split(a.itemNo);
    thisCategory=a.category(a.itemNo);
    thisX=a.X;
    thisY=a.y(:);
    thisY(a.y==thisLabel)=1;
    thisY(a.y~=thisLabel)=-1;
    %copy structure
    try
        trnIdx=a.trnSet{thisSplit};
        tstIdx=a.tstSet{thisSplit};

        sX=max(0.01,std(thisX(:,trnIdx),[],2));
        %thisX=thisX-repmat(mX(:),1,size(thisX,2));
        %thisX=diag(1./sX)*thisX;
        model=cvLeastSquareRegu(thisX(:,trnIdx),thisY(trnIdx));
        r.label=thisLabel;
        r.split=thisSplit;
        r.cat  =thisCategory;
        r.m={model};
        %evaluate on test set
        yhat=LeastSquareReguC(thisX(:,tstIdx),model);
        yhat=yhat(:);thisY=thisY(:);
        r.acc=mean(sign(yhat)==thisY(tstIdx));
        r.yhat={yhat(:)};
        %make colvectors
        a.y=a.y(:);
        r.gt={a.y(tstIdx)};
     catch
         err=lasterror;
         disp('error')
         keyboard;
     end;    
%-----------------------------------------------
function r=combine_classify(p,a,input)
  %sort by splits
  for s=1:p.splits
      idx=find(a.items.split==s);
      r.res(s).pred=cell2mat(a.items.yhat(idx));
      r.res(s).gt  =cell2mat(a.items.gt(idx));
      r.res(s).cat =a.items.cat(idx);
      r.res(s).label=a.items.label(idx);
  end;    

