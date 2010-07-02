%------------------------------------------------------------------------
%
%
%
%sharat@mit.edu
%-----------------------------------------------------------------------
function Model = multiclass_svm_train(X,y)
    class = unique(y);
    M     = length(class);
    Model = {};
    h     = waitbar(0);
    midx  = 1;
    for i = 1:M
      Xi  = X(:,y==class(i));
      for j = i+1:M
        waitbar(midx/(M*(M-1)/2),h,sprintf('Updated:%d of %d',midx,(M*(M-1)/2)));
    	Xj         = X(:,y==class(j));
        XTrain     = [Xi,Xj];
    	ytrain     = [ones(size(Xi,2),1);-ones(size(Xj,2),1)];
        model      = CLSosusvm(XTrain,ytrain);  %training
    	Model{i,j} = model;
    	Model{j,i} = model;
        midx       = midx+1;
      end;
    end;
    close(h);
%end function
