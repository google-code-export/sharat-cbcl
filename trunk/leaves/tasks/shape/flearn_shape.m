function t=flearn_default(varargin)
    t=struct;
    t.start=@start_flearn;
    t.item=@item_flearn;
    t.combine=@combine_flearn;

%-----------------------------------------------
function a=start_flearn(p,a,input)
   %isolate examples for dictionary learning
   idx=find(input.isHold);
   fnames=fieldnames(input);
   for i=1:length(fnames)
       a.(fnames{i})=input.(fnames{i})(idx);
   end;
   a.count=length(a.(fnames{1}));
   a.batchSize=10;

%-----------------------------------------------
function r=item_flearn(p,a,input)
  img=readLeafImage(p.home,char(a.filename(a.itemNo)));
  %copy fields
  try
      ftr=feval(p.callback,img,a.familyid(a.itemNo),a.orderid(a.itemNo));
      r.X=ftr(:);
      r.good=1;
  catch
      err=lasterror;
      fprintf('Error!')
      r.X=zeros(p.ftrlen,1);
      r.good=0;
      keyboard;
  end;
%end function

%-----------------------------------------------
function r=combine_flearn(p,a,input)
   r=a;
   r=rmfield(r,'items'); 
   r.X=a.items.X;
 
