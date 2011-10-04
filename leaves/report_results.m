function report_results(jobname)
    output_folder = date;
    mkdir(output_folder);
    figure;report(jobname,'family');
    figure;report(jobname,'order');
    report_pairs(jobname);

function report(jobname,what)   
   acc=[];
   load(fullfile(workdir,jobname,what));
   eval(['diary ' fullfile(date, [what  '.txt'])])
   for s=1:length(res)
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
   fprintf('---------------\n')   
   fprintf('%s\n',what);
   fprintf('---------------\n')
   fprintf('Results:%f +- %f\n',mean(diag(mean(C,3))),std(diag(mean(C,3))));
   fprintf('Results:%f +- %f\n',mean(acc),std(acc)/sqrt(3));
   diary off
    
function report_pairs(jobname)
    eval(['diary ' fullfile(date,'pairs.txt')])
    load(fullfile(workdir, jobname, 'pairs'))
    acc = [];
    fprintf('---------------------\n');
    fprintf('Pair wise accuracies:\n');
    fprintf('---------------------\n')
    for s = 1:length(res)
       acc = cat(1, acc, res(s).acc);    
    end;
    macc = mean(acc); sacc = std(acc)/sqrt(length(res));
    for p = 1:length(res(1).acc)
       fprintf('%s,%s:%f +- %f\n', ...
               char(res(1).first_cat(p)), char(res(1).second_cat(p)),...
               macc(p), sacc(p));
    end;
    %construct dendogram
    variants = {'single', 'complete', 'average'};
    num_classes = length(unique([res(1).first_label, res(1).second_label]));
    labels = [res(1).first_cat(1), res(1).second_cat(1:num_classes-1)];
    for i = 1:length(variants)
        l = linkage(1./(macc.^2), variants{i});
        figure; dendrogram(l, 'labels', labels, 'orient', 'right');
        method = sprintf('Family dendrogram (method:%s)', variants{i});
	title(method)
	print(gcf, '-djpeg100', fullfile(date, [method '.jpg']));
    end;
    diary off
