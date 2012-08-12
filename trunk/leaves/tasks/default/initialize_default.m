%------------------------------------------
%Creates a initialize
% Input
%  p-struct of parameters (defined in basicjob.m)
%  a-argument
% tasks/default/initialize_default:
%  ouput:
%  family
%  genus
%  order
%  isHold
%  mag 
%  source
%  familyid
%  genusid
%  orderid
%  sharat@mit.edu
%---------------------------------------------
function t=initialize_default(varargin)
	 varargin{:}
   t=struct;
   t.start=@start_initialize;
   t.item=@item_initialize;
   t.combine=@combine_initialize;
   
%------------------------------------------------
function a=start_initialize(p,a, varargin)    
 keyboard;
 files=dir(fullfile(p.home,'*.jpg'));
 files=files(randperm(length(files)));
 a.batchSize=100;
 a.count=length(files);
 a.files={files.name};
 fprintf('%d files being processed\n',a.count)
 %get hold off set
 randIdx=randperm(a.count);
 a.isHold=zeros(1,a.count);
 a.isHold(randIdx(1:ceil(p.holdFraction*a.count)))=1;
 %create the order-family map
 pairs=textscan(fopen('orderfamily.csv'),'%s');
 pairs=pairs{1};
 a.ordermap=hashtable;
 for i=1:length(pairs)
     [order,family]=strtok(pairs{i},',');
     family=family(2:end);
     a.ordermap(family)=order;
 end;    

%------------------------------------------------
function r=item_initialize(p,a)
  %get category
  r.filename=a.files(a.itemNo);
  [family,rest]=strtok(char(r.filename),'_');
  genus=strtok(rest,'_');  
  r.family={family};
  r.order={a.ordermap(family)};
  r.isHold=a.isHold(a.itemNo);
  match=regexp(char(r.filename),'\[(?<mag>\d+.\d+)x\].jpg','names');
  r.mag=str2num(match.mag);
  match=regexp(char(r.filename),'\{(?<source>.*)\}','names');
  r.source={match.source};

%------------------------------------------------
function r=combine_initialize(p,a)
try
  disp('Combining initialize')
  r=a.items;
  [families, iaf, icf] =unique(r.family);
  [orders, iao, ico] =unique(r.order);
  valid_order = is_valid(ico, p.minCount);
  valid_family = is_valid(icf, p.minCount);
  valid = valid_order & valid_family
  fnames = fieldnames(r)
  %get holdout data
  out = struct;
  hold = r.isHold;
  %filter out
  for i = 1:length(fnames)
    out.data.(fnames{i}) = r.(fnames{i})(valid & ~hold);
    out.holdout.(fnames{i}) = r.(fnames{i})(valid & hold);
  end;
  r = out;
  % get unique names and ids
  [r.data.family_names,dummy, r.data.familyid] = unique(r.data.family)
  [r.data.order_names, dummy, r.data.orderid] = unique(r.data.order)
	%random control assignments
	r.data.random_familyid = r.data.familyid(randperm(length(r.data.familyid)));
	r.data.random_orderid = r.data.orderid(randperm(length(r.data.orderid)));
  % get splits
  [r.test.orderid, r.train.orderid ] = split_data(r.data.orderid, p.splits);
  [r.test.familyid, r.train.familyid ] = split_data(r.data.familyid, p.splits);
  [r.test.random_familyid, r.train.random_familyid ] =...
		split_data(r.data.random_familyid, p.splits);
  [r.test.random_orderid, r.train.random_orderid ] =...
		split_data(r.data.random_orderid, p.splits);
catch
	err = lasterror;
	keyboard;
end;

function valid = is_valid(y, min_count)
  valid=true(1,length(y));
  [n,x]=hist(y,unique(y(:)));
  for i=1:length(n)
      if(n(i)< min_count)
        valid(y == x(i))=false;        
      end;
  end;    
