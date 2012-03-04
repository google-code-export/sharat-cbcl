%------------------------------------------
%Creates a split
% Input
%  p-struct of parameters (defined in basicjob.m)
%  a-argument
% tasks/default/split_default:
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
function t=split_default(varargin)
   t=struct;
   t.start=@start_split;
   t.item=@item_split;
   t.combine=@combine_split;
   
%------------------------------------------------
function a=start_split(p,a)    
 files=dir(fullfile(p.home,'*.jpg'));
 %DEBUG REMOVE LATER
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
function r=item_split(p,a)
  %get category
  r.filename=a.files(a.itemNo);
  [family,rest]=strtok(char(r.filename),'_');
  genus=strtok(rest,'_');  
  r.family={family};
  r.genus={genus};
  r.order={a.ordermap(family)};
  r.isHold=a.isHold(a.itemNo);
  match=regexp(char(r.filename),'\[(?<mag>\d+.\d+)x\].jpg','names');
  r.mag=str2num(match.mag);
  match=regexp(char(r.filename),'\{(?<source>.*)\}','names');
  r.source={match.source};

%------------------------------------------------
function r=combine_split(p,a)
  disp('Combining split')
  r=a.items;
  families=unique(r.family);
  orders=unique(r.order);
  genus=unique(r.genus);
  %get unique families
  for i=1:length(r.filename)
    r.familyid(i)=find(strcmp(r.family{i},families),1);
    r.orderid(i)=find(strcmp(r.order{i},orders),1);
    r.genusid(i)=find(strcmp(r.genus{i},genus),1);
  end;    
