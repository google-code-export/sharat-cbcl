function report_results(jobname)
    figure;report(jobname,'family');
    figure;report(jobname,'order');

function report(jobname,what)   
   acc=[];
   load(fullfile(workdir,jobname,what));
   for s=1:length(res)
    fprintf('Split:%d\n',s)
    [val,yhat]=sort(res(s).pred,2,'descend');
    yhat=res(s).label(yhat(:,1));
    gt  =res(s).gt(:,1);
    acc(s)=mean(yhat(:)==gt(:));
    C(:,:,s)=confusion_matrix(yhat(:),gt(:),res(s).label(:));
   end;    
   C(isnan(C))=0;
   imagesc(mean(C,3));
   axis xy;
   set(gca,'XTick',1:length(res(s).cat));
   set(gca,'YTick',1:length(res(s).cat));
   set(gca,'XTickLabel',res(s).cat);
   set(gca,'YTickLabel',res(s).cat);
   set(gcf,'Name',what)
   rotateticklabel(gca,90);
   fprintf('What:%s\n',what);
   fprintf('---------------\n')
   fprintf('Results:%f +- %f\n',mean(diag(mean(C,3))),std(diag(mean(C,3))));
   fprintf('Results:%f +- %f\n',mean(acc),std(acc)/sqrt(3));
