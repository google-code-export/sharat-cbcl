function t=flearn_default(varargin)
   t=struct;
   t.start=@start_flearn;
   t.item=@item_flearn;
   t.combine=@combine_flearn;

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


