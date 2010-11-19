function t=matrix_default(varargin)
    t=struct;
    t.start=@start_matrix;
    t.item=@item_matrix;
    t.combine=@combine_matrix;

%-----------------------------------------------
%note that  
function a=start_matrix(p,a,input,ref)
   warning('off','all')
   %isolate train/test
   a.count=size(input.X,2);
   a.batchSize=100;
   a.ref      =ref;
   a.ref.X    =a.ref.X(:,randperm(size(ref.X,2)));
   a.ref.X    =a.ref.X(:,1:min(200,size(ref.X,2)))
%-----------------------------------------------
function r=item_matrix(p,a,input,ref)
ref=a.ref;
try
  %copy fields
  ftrX = input.X(:,a.itemNo);
  ptX  = reshape(ftrX(1:200),[100 2]);
  shapeX=ftrX(201:end);
  r.X =[];
  for i=1:size(ref.X,2)
     if(mod(i,10)==0)
         fprintf('%d..',i)
     end;
     ftrY   =ref.X(:,i);
     ptY    =reshape(ftrY(1:200),[100 2]);
     shapeY =ftrY(201:end);
     [sc_cost,aff_cost,match_cost]=tps_iter(ptX(1:2:end,:),ptY(1:2:end,:));
     ftr = [sc_cost;aff_cost;match_cost;norm(shapeX(:)-shapeY(:))];
     r.X=cat(1,r.X,ftr(:));
  end;
  r.good=1;
catch
  err=lasterror;
  r.X = zeros(4*size(ref.X,2),1);
  r.good=0;
end;  
%end function

%-----------------------------------------------
function r=combine_matrix(p,a,input,ref)
   r=input;
   r=rmfield(r,'X'); 
   r.X=a.items.X;
   r.X(isnan(r.X))=0;
 
