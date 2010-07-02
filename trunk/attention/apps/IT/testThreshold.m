load training_data_gabriel;
load thresholdGabriel;
%---------------------------
%determine pO
Y=remap(Y,{[0:2],[3],[4],[5],[6],[7:8]},[4,1,2,4,3,4])
for obj=unique(Y)
  for f=1:size(X,2)
	pO(f,obj)=min(0.95,max(0.05,mean(X(Y==obj,f)>thresh(f,9))));
  end;
end;  
pO(:,end+1)=0.01;
pO(:,end+1)=0.5;


score1 = zeros(8,size(X,2));
score0 = zeros(8,size(X,2));
for o = 1:3
  fprintf('.');
  for j = 1:size(X,2)
    s1    = 0;
    s0    = 0;
    for i = 1:size(X,1)
	s1 = s1+X(i,j)*log(p(o,i)+eps)+(1-X(i,j))*log(1-p(o,i)+eps);
	s0 = s0+X(i,j)*log(q(o,i)+eps)+(1-X(i,j))*log(1-q(o,i)+eps);
  end;
  
    s1 = s1+log(1/2);
    s0 = s0+log(1/2);
    score1(o,j) = s1;
    score0(o,j) = s0;
  end;
end;
