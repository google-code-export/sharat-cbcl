function report_results(jobname)
   load(fullfile(workdir,jobname,'classify'));
   acc=[];
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
   rotateticklabel(gca,90);
