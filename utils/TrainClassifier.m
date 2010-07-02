%-----------------------------------------------------
%function model = TrainClassifier(X,Y,type)
%X      DxN , D-dimension,N-number of data points
%Y      Nx1   1/-1
%type   'SVM','RLS','ADABOOST' 'GBOOST'
%sharat@mit.edu
%
%-----------------------------------------------------
function model = TrainClassifier(X,Y,type)
    switch(type)
        case 'SVM'
            model.classifier=cvsvmtrain(Y,X');
            model.type      ='SVM';
        case 'RLS'
            model.classifier=cvLeastSquareReg(X,Y);
            model.type      ='RLS'
        case 'GBOOST'
            model.classifier=cvgentleBoost(X,Y);
            model.type      ='GBOOST'
        otherwise
            error('type not supported')
    end;
%end function
