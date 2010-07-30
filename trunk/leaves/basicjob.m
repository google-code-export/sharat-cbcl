function p=basicjob
    p=struct;
    p.func=''
    p.home='/cbcl/scratch01/sharat/databases/LeavesAll';
    p.holdFraction=0.05;
    p.splits=3;
    p.callback='callback_hist_leaves';
    p.ftrlen=193;
    p.minCount=100;
    p.tasks={};
    p.desc='';
    %split the files
    t=struct;
    t.name='split'
    t.args=struct;
    t.start=@start_split;
    t.item=@item_split;
    t.combine=@combine_split;
    p.tasks{end+1}=t;
    %dictionary learning
    t=struct;
    t.name='flearn'
    t.args=struct;
    t.start=@start_flearn;
    t.item=@item_flearn;
    t.combine=@combine_flearn;
    t.depends={'split'};
    p.tasks{end+1}=t;
    %feature extraction
    t=struct;
    t.name='fextract';
    t.args=struct;
    t.start=@start_fextract;
    t.item=@item_fextract;
    t.combine=@combine_fextract;
    t.depends={'flearn'};
    p.tasks{end+1}=t;
    %classification
    t=struct;
    t.name='classify';
    t.args=struct;
    t.start=@start_classify;
    t.item=@item_classify;
    t.combine=@combine_classify;
    t.depends={'fextract'};
    p.tasks{end+1}=t;

%-----------------------------------------------
function a=start_classify(p,a,input)
  %input X,y,catid,cat,name
  fnames=fieldnames(input);
  for i=1:length(fnames)
      a.(fnames{i})=input.(fnames{i});
  end;
  %find valid categories
  valid=ones(1,length(a.y));
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
      r.res(s).desc=p.desc;
  end;    
%-----------------------------------------------
function a=start_fextract(p,a,input)
   %isolate train/test
   idx=find(~input.isHold);
   fnames=fieldnames(input);
   for i=1:length(fnames)
       a.(fnames{i})=input.(fnames{i})(idx);
   end;
   a.count=length(a.catid);
   a.batchSize=100;

%-----------------------------------------------
function r=item_fextract(p,a,input)
  img=readLeafImage(p.home,char(a.name(a.itemNo)));
  r.y=a.catid(a.itemNo);
  try
      ftr=feval(p.callback,img);
      r.X=ftr(:);
      r.good=1;
  catch
      err=lasterror;
      fprintf('Error!')
      r.X=zeros(p.ftrlen,1);
      r.good=0;
  end;
%end function

%-----------------------------------------------
function r=combine_fextract(p,a,input)
   r=a;
   r.X=a.items.X;
   r.y=a.items.y;
   r=rmfield(r,'items'); 
%-----------------------------------------------
function a=start_flearn(p,a,input)
  disp('Learning dictionary')
  a.count=1;
  a.batchSize=1;

%------------------------------------------------
function r=item_flearn(p,a,input)
    r.x=0;
%-----------------------------------------------

function r=combine_flearn(p,a,input)
   disp('Done learning dictionary')
   r=input;

%------------------------------------------------
function a=start_split(p,a)    
 disp('starting split');
 files=dir(fullfile(p.home,'*.jpg'));
 %DEBUG REMOVE LATER
 files=files(randperm(length(files)));
 a.batchSize=100;
 a.count=length(files);
 a.files={files.name};
 %get hold off set
 randIdx=randperm(a.count);
 a.isHold=zeros(1,a.count);
 a.isHold(randIdx(1:ceil(p.holdFraction*a.count)))=1;

%------------------------------------------------
function r=item_split(p,a)
  %get category
  r.name=a.files(a.itemNo);
  r.cat=strtok(r.name,'_');
  r.isHold=a.isHold(a.itemNo);
  match=regexp(r.name,'\[(?<mag>\d+.\d+)x\].jpg','names');
  r.mag=str2num(match{1}.mag);

%------------------------------------------------
function r=combine_split(p,a)
  disp('Combining split')
  fnames=fieldnames(a.items);
  for f=1:length(fnames)
    r.(fnames{f})=a.items.(fnames{f});
  end;
  table=hashtable;cnt=0;
  for i=1:length(r.name)
    fprintf('%d\n',i)
    name=r.cat{i};
    if(iskey(table,name))  
        r.catid(i)=get(table,name);
        continue;
    else
        cnt=cnt+1;
        r.catid(i)=cnt;
        table(name)=cnt;
    end;    
  end;    
