function report_results(jobname)
    output_folder = date;
    mkdir(output_folder);
    figure;report(jobname,'family');
    figure;report(jobname,'order');
    report_pairs(jobname, 'pairs', 'pairwise_accuray');
    report_pairs(jobname, 'fda', 'pairwise_lda_separability');
    %report_pairs(jobname, 'family_confusion', 'pairwise_confusion');

    
function write_confusion_matrix(C, cat, jobname, what)
%sort by splits
  res = [];
  for s=1:size(C,3)
      acc = [];
      first_cat = [];
      second_cat = [];
      for i = 1:size(C,1)
           for j = i+1:size(C,2)
            first_cat = [first_cat, cat(i)];
            second_cat = [second_cat, cat(j)];
            acc=[acc, C(i,j,s)];
           end
      end
      res(s).first_cat = first_cat;
      res(s).second_cat = second_cat;
      res(s).first_label = first_cat;
      res(s).second_label = second_cat;
      res(s).acc = acc + 1e-4*rand(size(acc));
  end;
  save(fullfile(workdir, jobname, what), 'res')

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
   write_confusion_matrix(C,res(s).cat,jobname, [what '_confusion' ])
   C(isnan(C))=0.0;
   C = C + 1e-4*rand(size(C));
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

    
function report_pairs(jobname, what, name)
    eval(['diary ' fullfile(date, name) '.txt'])
    load(fullfile(workdir, jobname, what))
    acc = [];
    fprintf('---------------------\n');
    fprintf('Pair wise measure(%s):\n',name);
    fprintf('---------------------\n')
    for s = 1:length(res)
       acc = cat(1, acc, res(s).acc);    
    end;
    macc = mean(acc); sacc = std(acc)/sqrt(length(res)+1e-6);
    for p = 1:length(res(1).acc)
       fprintf('%s,%s:%f +- %f\n', ...
               char(res(1).first_cat(p)), char(res(1).second_cat(p)),...
               macc(p), sacc(p));
    end;
    %construct dendogram
    variants = {'complete', 'average'};
    num_classes = length(unique([res(1).first_label, res(1).second_label]));
    labels = [res(1).first_cat(1), res(1).second_cat(1:num_classes-1)];
    for i = 1:length(variants)
	      l = linkage(-log(macc+1e-6), variants{i});
        figure; dendrogram(l, 'labels', labels, 'orient', 'right');
        method = sprintf('dendrogram(method:%s)', variants{i});
	title(method)
	%print(gcf, '-djpeg100', fullfile(date, [what '-' method '.jpg']));
    end;
    diary off
