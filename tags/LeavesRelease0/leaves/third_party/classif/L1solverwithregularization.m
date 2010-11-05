function [x,fval,prex,residu] = L1solverwithregularization(A,b,lambda);
%solve A^\top h = b

[nfeatures,nexamples] = size(A);
%first x plus x minus than residu plus residu minus
f = [lambda*ones(2*nfeatures,1); ones(2*nexamples,1)];
Agt = -eye(2*nexamples+2*nfeatures);
bgt = zeros(2*nexamples+2*nfeatures,1);
Aeq = [A' -A' eye(nexamples) -eye(nexamples)];
beq = b;
opts = optimset('Display','off');
[x,fval] = linprog(f,[],[],Aeq,beq,zeros(2*nexamples+2*nfeatures,1),[],[],opts);
prex = x;
x = x(1:nfeatures)-x((nfeatures+1):(2*nfeatures));

if 0
fval2 = sum(abs(A'*x-b)) + lambda*sum(abs(x));
[fval fval2]
end
