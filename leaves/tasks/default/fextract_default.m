function t=fextract_default(varargin)
    t=struct;
    t.start=@start_fextract;
    t.item=@item_fextract;
    t.combine=@combine_fextract;

%-----------------------------------------------
% input contains the results of initialize_default
function a=start_fextract(p,a,input,dictionary)
   a.count=length(input.data.familyid);
   a.batchSize=100;

%-----------------------------------------------
function r=item_fextract(p,a,input, dictionary)
  img=readLeafImage(p.home,char(input.data.filename(a.itemNo)));
  %copy fields
  try
      ftr=feval(p.callback,img,...
								input.data.familyid(a.itemNo),...
								input.data.orderid(a.itemNo));
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
function r=combine_fextract(p,a,input, dictionary)
   r=a;
   r=rmfield(r,'items'); 
   r.X=a.items.X;
 
