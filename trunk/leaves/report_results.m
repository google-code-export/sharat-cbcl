function report_results(jobname)
  output_folder = date;
  mkdir(output_folder);
	close all;
	delete(fullfile(date, '*'))
  figure;report(jobname,'family');
  figure;report(jobname,'order');
	report_correlation(jobname, 'family_confusion_matrix', 'family-pairs', '(x+eps)', '-(x+eps)')

function scores = load_pair_distances(filename)
	pairs = importdata(filename, ',', 0);
	scores = hashtable;
	for i = 1:length(pairs.data)
		scores(sprintf('%s,%s',pairs.textdata{i,1}, pairs.textdata{i,2})) = pairs.data(i,1);
	end;
		
function report_correlation(jobname, score_file, distance_folder, afun, bfun)
    eval(['diary ' fullfile(date, ['correlation'  '.txt'])])
	distance_files=dir(distance_folder);
	pairs = importdata([fullfile(date,score_file) '.txt'], ',', 0);
	ref = hashtable;
	%load up the reference scores
	for i = 1:length(pairs.textdata)
		ref(sprintf('%s,%s',pairs.textdata{i,1},...
			pairs.textdata{i,2})) = pairs.data(i,1);
	end;
	refkeys = keys(ref);
	for i = 1:length(distance_files)
		if(distance_files(i).isdir) continue; end;
		comp = load_pair_distances(fullfile(distance_folder, distance_files(i).name));
		common_scores = [];
		for j = 1:length(refkeys)
            if iskey(comp,refkeys(j))
				common_scores = cat(1, common_scores, [ref(refkeys(j)), comp(refkeys(j))]);	
			else
				fprintf('WUT?\n')
			end;
		end;
		a = max(1e-8, common_scores(:,1));
		b = max(1e-8, common_scores(:,2));
		tx_functions = { 'log(x)', 'sqrt(x)', '1./(x)', 'x', 'exp(1./x)', 'exp(x)', 'exp(-x)', '1./(1+exp(-x))',...
						 '1./sqrt(x)', 'tanh(x)', 'x.^0.1'};
		corr_max = 0; tx_a = ''; tx_b = '';
		for u = 1:length(tx_functions)
			for v = 1:length(tx_functions)
				corr_val = corrcoef(feval(inline(tx_functions{u}),a),...
									feval(inline(tx_functions{v}),b));
				if(any(isnan(corr_val(:)))) continue; end;
				if(abs(corr_val(1,2))>corr_max)
					tx_a = tx_functions{u};
					tx_b = tx_functions{v};
					corr_max = abs(corr_val(1,2));
				end;
			end;
		end;
		%plot(feval(inline(tx_a),a),feval(inline(tx_b),b),'.');title(sprintf('%s,%s,:%f',tx_a,tx_b,corr_max));pause;
		fprintf('%s(%s),%s(%s),%f\n', score_file, tx_a, distance_files(i).name, tx_b,corr_max);
	end;	
	fprintf('\n\n')
	diary off


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
   C(isnan(C))=0.0;
   imagesc(mean(C,3));
   axis xy;
   set(gca,'XTick',1:length(res(s).cat));
   set(gca,'YTick',1:length(res(s).cat));
   set(gca,'XTickLabel',res(s).cat);
   set(gca,'YTickLabel',res(s).cat);
   set(gcf,'Name',what)
   rotateticklabel(gca,90);
   colorbar;
   print(gcf, '-djpeg100', fullfile(date, [what '_confusion_matrix.jpg']));
   fprintf('---------------\n')   
   fprintf('%s\n',what);
   fprintf('---------------\n')
   fprintf('Results:%f +- %f\n',mean(diag(mean(C,3))),std(diag(mean(C,3))));
   fprintf('Results:%f +- %f\n',mean(acc),std(acc)/sqrt(3));
   diary off
   eval(['diary ' fullfile(date, [what '_confusion_matrix.txt'])])
   for i = 1:length(res(1).cat)
	for j = i+1 :length(res(1).cat)
		fprintf('%s,%s,%f,%f\n',...
				res(1).cat{i}, res(1).cat{j},...
				mean(C(i,j,:)),std(C(i,j,:))/sqrt(10));
	end;
   end;		
   diary off

function report_pairs(jobname, what, name, fun)
    eval(['diary ' fullfile(date, name) '.txt'])
    load(fullfile(workdir, jobname, what))
    acc = [];
    for s = 1:length(res)
       acc = cat(1, acc, res(s).acc);    
    end;
	
	%generate confusion matrix from this?
	uniq_cat = unique(cat(2,res(1).first_cat, res(1).second_cat));
	confusion_matrix = zeros(length(uniq_cat));
    macc = mean(acc); sacc = std(acc)/sqrt(length(res)+1e-6);
	ucat = {}; vcat= {};
    for p = 1:length(res(1).acc)
      fprintf('%s,%s,%f,%f\n', ...
              char(res(1).first_cat(p)), char(res(1).second_cat(p)),...
              macc(p), sacc(p));
      uidx = find(strcmp(res(1).first_cat(p), uniq_cat));
      vidx = find(strcmp(res(1).second_cat(p), uniq_cat));
	  ucat = cat(1,ucat,uniq_cat{uidx});
	  vcat = cat(1,vcat,uniq_cat{vidx});
      confusion_matrix(uidx,vidx) = feval(inline(fun),macc(p));
    end;
	% make the confusion matrix symmetric
	% fill in the diagonal
	confusion_matrix = confusion_matrix + confusion_matrix';
	confusion_matrix = confusion_matrix + eye(size(confusion_matrix))*max(confusion_matrix(:));
	imagesc((confusion_matrix'));
	axis xy;
	set(gca,'XTick',1:length(uniq_cat));
	set(gca,'YTick',1:length(uniq_cat));
	set(gca,'XTickLabel',vcat(1:length(uniq_cat)));
	set(gca,'YTickLabel',vcat(1:length(uniq_cat)));
	set(gcf,'Name',what)
	rotateticklabel(gca,90);
	colorbar;
	print(gcf, '-djpeg100', fullfile(date, [what '_pairs_confusion_matrix.jpg']));
    %construct dendogram
    variants = {'complete', 'average'};
    num_classes = length(unique([res(1).first_label, res(1).second_label]));
    labels = [res(1).first_cat(1), res(1).second_cat(1:num_classes-1)];
    for i = 1:length(variants)
	      l = linkage(-log(macc+1e-6), variants{i});
        figure; dendrogram(l, 'labels', labels, 'orient', 'right');
        method = sprintf('dendrogram(method:%s)', variants{i});
	title(method)
	print(gcf, '-djpeg100', fullfile(date, [what '-' name '-' method '.jpg']));
    end;
    diary off
