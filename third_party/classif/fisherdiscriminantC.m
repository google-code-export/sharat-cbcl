function DecValue = fisherdiscriminantC(X, Model)


w        = Model.w;
DecValue = w'*[ones(1,size(X,2)); X];
