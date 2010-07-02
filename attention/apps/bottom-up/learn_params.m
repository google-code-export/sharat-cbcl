%----------------------------------------------------------------
%
%sharat@mit.edu
%
TRNDIR='/cbcl/scratch04/sharat/data/csailIOC2ClusteredEx';
trnFiles=dir(fullfile(TRNDIR,'C2_01*.mat'));
trnFiles=trnFiles(randperm(length(trnFiles)));
load(fullfile(TRNDIR,trnFiles(1).name),'ftr');
nPatches=size(ftr{2}{1},3);
xData   =cell(nPatches,1);
QTL     =0.9;
for i=1:min(300,length(trnFiles))
 fprintf('Processing %d of %d\n',i,length(trnFiles));
 for p=1:nPatches
     for b=2:length(ftr{2})
        plane   =ftr{2}{b}(:,:,p);
        xData{p}=cat(1,xData{p},plane(:));
    end;
    model.thresh(p)=quantile(xData{p},QTL);
    model.qtl(p)   =QTL;
 end;
end;
save aim_model_90Clustered model;
