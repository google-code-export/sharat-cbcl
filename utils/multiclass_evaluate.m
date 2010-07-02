%------------------------------------------------------------------------
%
%
%
%sharat@mit.edu
%-----------------------------------------------------------------------
function multiclass_evaluate(CLASSES,TRAINING)
   load c2_101_baseline_01
   if(nargin==0)
     TRAINING = 15;
     CLASSES  = 10;
   end;
   avg_rate = [];
   %-------------------------------   
   %select random classes
   %-------------------------------
   x       = unique(y);
   idx     = randperm(length(x));
   x       = x(idx(1:CLASSES));
   for trials = 1:10
        x_train  = [];
        y_train  = [];
        x_test   = [];
        y_test   = [];  
        %----------------------------------
        %generate training and testing
        %-------------------------------
        for i = 1:CLASSES
         num_total = sum(y==x(i));    %number of samples
         num_train = TRAINING;
         num_test  = min(50,num_total-num_train);
         %---------------------------------------
         %randomize input
         %---------------------------------------
         Xi        = X(:,y==x(i));
         xidx      = randperm(num_total);
         Xi        = Xi(:,xidx); 
         %---------------------------------------
         %extract training and test
         %---------------------------------------
         x_train = [x_train,Xi(:,1:num_train)];
         x_test  = [x_test,Xi(:,num_train+1:num_train+num_test)];
         y_train = [y_train;i*ones(num_train,1)];
         y_test  = [y_test;i*ones(num_test,1)];
         end;
         
         %---------------------------------------
         %train a multi-class SVM
         %---------------------------------------
         Model   = multiclass_svm_train(x_train,y_train);
         yhat    = multiclass_svm_test(x_test,Model)';

         rate  = 0;
         %---------------------------------------
         %get recognition rate
         %---------------------------------------
         for i =1:length(x)
           idx          = find(y_test==i);
           tmp_rate     = sum(yhat(idx)==y_test(idx))/length(idx);
           %fprintf('class: %d-->%f\n',i,tmp_rate);
           fprintf('.');
           rate         = rate+tmp_rate;
         end;
         fprintf('\nRATE:%d\n',rate/length(x)*100);
         avg_rate = [avg_rate,rate/length(x)*100];
   end;
   fprintf('AVERAGE RATE:(%f,%f)\n',mean(avg_rate),std(avg_rate));
% function 

