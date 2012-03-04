function t=all_pairs_lda(varargin)
    t=struct;
    t.start=@start_pairs_lda;
    t.item=@pair_lda;
    t.combine=@combine_pair_lda;

%-----------------------------------------------
function a=start_pairs_lda(p,a,input)
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
function r=pair_lda(p,a,input)
    firstLabel=a.first_label(a.itemNo);
    secondLabel=a.second_label(a.itemNo);
    thisSplit=a.split(a.itemNo);
    firstCategory=a.first_category(a.itemNo);
    secondCategory=a.second_category(a.itemNo);
    validIdx = find(a.y(:)==firstLabel | a.y(:) == secondLabel);
    thisX=a.X(:,validIdx);
    thisY=a.y(validIdx);
    thisX=thisX + randn(size(thisX))*1e-4;
    thisY = 2*ones(size(thisY));
    thisY(a.y(validIdx)==firstLabel) = 1;
    %copy structure
    try
        r.first_label=firstLabel;
        r.second_label=secondLabel;
        r.split=thisSplit;
        r.first_cat  = firstCategory;
        r.second_cat  = secondCategory;
        %Fit a LDA model
        model = fld(struct('X',thisX, 'y', thisY))
        r.acc=model.separab;
        fprintf('Separability:%f\n',r.acc);
        %make colvectors
     catch
         err=lasterror;
         disp('error')
         keyboard;
     end;    
%-----------------------------------------------
function r=combine_pair_lda(p,a,input)
  %sort by splits
  for s=1:p.splits
      idx=find(a.items.split==s);
      r.res(s).first_cat =a.items.first_cat(idx);
      r.res(s).second_cat =a.items.second_cat(idx);
      r.res(s).first_label=a.items.first_label(idx);
      r.res(s).second_label=a.items.second_label(idx);
      r.res(s).acc = a.items.acc(idx);
  end;    

