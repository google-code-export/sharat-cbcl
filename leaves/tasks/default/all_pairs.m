function t=all_pairs(varargin)
    t=struct;
    t.start=@start_pairs;
    t.item=@pair_classify;
    t.combine=@combine_pair;

%-----------------------------------------------
function a=start_pairs(p,a,input)
  disp('Start classify')
  %input X,y,catid,cat,name
  fnames=fieldnames(input);
  for i=1:length(fnames)
      a.(fnames{i})=input.(fnames{i});
  end;
  a.y=a.familyid;
  %find valid categories
  valid=ones(1,length(a.y));
  [n,x]=hist(a.y,unique(a.y(:)));
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
  disp('Creating split')
  %create splits
  [uclass,ui,uj]=unique(a.familyid);
  a.batchSize=1;
  a.split=[];
  a.first_label=[];
  idx=0;
  for s=1:p.splits
      disp(s)
      for u=1:length(uclass)
        for v = (u+1):length(uclass)
	  idx = idx + 1
          a.split(idx)=s;
          a.first_label(idx)=uclass(u);
          a.second_label(idx)=uclass(v);
          a.first_category(idx)=a.family(ui(u));
          a.second_category(idx)=a.family(ui(v));
        end; %v
      end; %u
  end;    
  a.count = idx;
  keyboard;

%-----------------------------------------------
function r=pair_classify(p,a,input)
    firstLabel=a.first_label(a.itemNo);
    secondLabel=a.second_label(a.itemNo);
    thisSplit=a.split(a.itemNo);
    firstCategory=a.first_category(a.itemNo);
    secondCategory=a.second_category(a.itemNo);
    validIdx = find(a.y(:)==firstLabel | a.y(:) == secondLabel);
    thisX=a.X(:,validIdx);
    thisY=a.y(validIdx);
    thisY = -1*ones(size(thisY));
    thisY(a.y(validIdx)==firstLabel) = 1;
    [tstSet,trnSet]=split_data(thisY(:),2);
    %copy structure
    try
        trnIdx=trnSet{1};
        tstIdx=tstSet{1};
        switch(p.classifier)
            case 'liblinear,'
            thisX=normalize_l2(thisX);
            model=train(thisY(trnIdx),sparse(thisX(:,trnIdx)),'-B 1','col');
            case 'rls'
            model=cvLeastSquareRegu(thisX(:,trnIdx),thisY(trnIdx));
            case 'libsvm'
            model=cvsvmtrain(thisY(trnIdx),thisX(:,trnIdx)');
        end;    
        r.first_label=firstLabel;
        r.second_label=secondLabel;
        r.split=thisSplit;
        r.first_cat  = firstCategory;
        r.second_cat  = secondCategory;
        r.m={model};
        %evaluate on test set
        switch(p.classifier)
            case 'liblinear'
             [bb,b,yhat]=predict(thisY(tstIdx),...
             sparse(thisX(:,tstIdx)),model,'','col');
             yhat=-yhat; %idiosyncracy of liblinear (orders by labels)
            case 'rls'
             yhat=LeastSquareReguC(thisX(:,tstIdx),model);
            case 'libsvm' 
             [bb,b,yhat]=svmpredict(thisY(tstIdx),thisX(:,tstIdx)',model);
             yhat=yhat*sign(thisY(trnIdx(1)));
        end;     
        thisY=thisY(:);yhat=yhat(:);
        r.acc=mean(sign(yhat)==thisY(tstIdx));
        fprintf('Testing accuracy:%f\n',r.acc);
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
function r=combine_pair(p,a,input)
  %sort by splits
  for s=1:p.splits
      idx=find(a.items.split==s);
      r.res(s).first_cat =a.items.first_cat(idx);
      r.res(s).second_cat =a.items.second_cat(idx);
      r.res(s).first_label=a.items.first_label(idx);
      r.res(s).second_label=a.items.second_label(idx);
      r.res(s).acc = a.items.acc(idx);
  end;    

