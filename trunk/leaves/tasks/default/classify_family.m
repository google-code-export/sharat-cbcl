function t=all_pairs(varargin)
		varargin{:}
    t=struct;
    t.start=@start_classify;
    t.item=@item_classify;
    t.combine=@combine_classify;

%-----------------------------------------------
function a=start_classify(p, a, splits, input)
 	a.count=p.splits;
  a.batchSize=1;

%-----------------------------------------------
function r=item_classify(p, a, splits, input)
		X = input.X';
		Y = input(a.label_field)(:);
		trainIdx = splits.train.(a.label_field){a.itemNo};
		testIdx = splits.test(a.label_field){a.itemNo};
  	model=cvsvmtrain(Y(trainIdx),X(trainIdx,:));
		[a,b,F] = svmpredict(Y(testIdx), X(testIdx,:));
    r.y= {a};
    r.gt={a.Y(tstIdx)};

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

