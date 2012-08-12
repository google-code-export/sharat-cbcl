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
		Y = splits.data.(a.label_field);
		Y = Y(:);
		train = splits.train.(a.label_field);
		test = splits.test.(a.label_field);
		trainIdx = train{a.itemNo};
		testIdx = test{a.itemNo};
		try
  		model=cvsvmtrain(Y(trainIdx),X(trainIdx,:));
		catch
			err = lasterror;
			keyboard;
		end;
		[yhat,b,F] = svmpredict(Y(testIdx), X(testIdx,:), model);
    r.y= {yhat};
    r.gt={Y(testIdx)};

%-----------------------------------------------
function r=combine_classify(p,a,splits, input)
	r = struct
	r.y = a.items.y
	r.gt = a.items.gt

