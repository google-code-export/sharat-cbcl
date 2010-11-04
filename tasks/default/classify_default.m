function t=classify_default(varargin)
    t=struct;
    t.start=@start_classify;
    t.item=@item_classify;
    t.combine=@combine_classify;

%-----------------------------------------------
function a=start_classify(p,a,input)
  %input X,y,catid,cat,name
  fnames=fieldnames(input);
  for i=1:length(fnames)
      a.(fnames{i})=input.(fnames{i});
  end;
  %find valid categories
  valid=ones(1,length(a.));
  [n,x]=hist(a.y,unique(a.y));
  for i=1:length(n)
      if(n(i)<p.minCount)
        valid(a.y==x(i))=0;        
      end;
  end;    
  %filter 
  for i=1:length(fnames)
      if(length(a.(fnames{i}))==length(valid))
          a.(fnames{i})=a.(fnames{i})(:,find(valid));
      end;
  end;    
  %create splits
  [uclass,ui,uj]=unique(a.catid);
  a.count=p.splits*length(uclass);
  a.batchSize=1;
  a.split=[];
  a.label=[];
  idx=1;
  for s=1:p.splits
      for u=1:length(uclass)
          a.split(idx)=s;
          a.label(idx)=uclass(u);
          a.category(idx)=a.cat(ui(u));
          idx=idx+1;
      end;
  end;    
  [tstSet,trnSet]=split_data(a.catid(:),p.splits);
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
        mX=mean(thisX(:,trnIdx),2);
        sX=max(0.01,std(thisX(:,trnIdx),[],2));
        %thisX=thisX-repmat(mX(:),1,size(thisX,2));
        %thisX=diag(1./sX)*thisX;
        model=cvsvmtrain(thisY(trnIdx),thisX(:,trnIdx)');
        %model=cvLeastSquareRegu(thisX(:,trnIdx),thisY(trnIdx));
        %model=train(thisY(trnIdx),sparse(thisX(:,trnIdx)'));%cvLeastSquareRegu(thisX(:,trnIdx),thisY(trnIdx));
        r.label=thisLabel;
        r.split=thisSplit;
        r.cat  =thisCategory;
        r.m={model};
        %evaluate on test set
        [bb,b,yhat]=svmpredict(thisY(tstIdx),thisX(:,tstIdx)',model);
        %[bb,b,yhat]=predict(thisY(tstIdx),sparse(thisX(:,tstIdx)'),model);
        %yhat=LeastSquareReguC(thisX(:,tstIdx),model);
        %yhat=yhat(:);thisY=thisY(:);
        yhat=yhat(:)*sign(thisY(trnIdx(1)));thisY=thisY(:);
        r.acc=mean(sign(yhat)==thisY(tstIdx));
        r.yhat={yhat(:)};
        %make colvectors
        a.y=a.y(:);
        a.cat=a.cat(:);
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

