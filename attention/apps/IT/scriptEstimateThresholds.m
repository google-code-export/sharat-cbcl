ftrHome='/cbcl/scratch04/sharat/gabriel/features-trn7x7';
nFtr   =40;
ftrFiles=dir(fullfile(ftrHome,'*.mat'));
samples={};
for f=1:length(ftrFiles)
  fprintf('%d of %d\n',f,length(ftrFiles));
  load(fullfile(ftrHome,ftrFiles(f).name),'ftr');
  c2=ftr{2};
  for d=1:size(c2,3)
	if(length(samples)<d)samples{d}=[];end;
	plane     =c2(:,:,d);
    samples{d}=cat(1,samples{d},plane(:));
  end;
end;
THRESH=0.05:0.05:1;
for d=1:size(c2,3)
  for t=1:length(THRESH)
	thresh(d,t)=quantile(samples{d},THRESH(t));
  end;
end;  
save threshGabriel7x7
