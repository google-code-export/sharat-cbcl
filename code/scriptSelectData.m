clear all;
close all;
load training_data_75ClassesShape X Y
Xorg=X; Yorg=Y;clear X Y;
class    =1;
X =[]; Y=[];mapping=[];
for lbl=unique(Yorg)'
  idx = find(Yorg==lbl);
  if(length(idx)>100)
    X      = [X,Xorg(:,idx)];
    Y      = [Y,class*ones(1,length(idx))];
    mapping= [mapping,lbl];
    class  = class+1;
  end;
end;
save training_data_8of8ClassesShape X Y mapping

%-----------------------------
%further selection
Xorg=X; Yorg=Y;
X =[]; Y=[];mapping=[];
class=1;
for lbl=unique(Yorg)
  idx=find(Yorg==lbl);
  if(any([1 3 5]==lbl))
    continue;
  end;
  X      = [X,Xorg(:,idx)];
  Y      = [Y,class*ones(1,length(idx))];
  class  = class+1;
end;  
save training_data_5of8ClassesShape X Y mapping
    
  
  
