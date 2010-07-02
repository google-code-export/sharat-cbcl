clear all;
close all;
load model_3;
load img_set_animals;
Xd=zeros(12800,length(img_set));
Xq=zeros(400,length(img_set));

for i=1:length(img_set)
  fprintf('Processing %d of %d\n',i,length(img_set));
  img_set{i}=imresize(img_set{i},0.5,'bicubic');
  [out,res,dout]=quantize_domain(img_set{i},model);
  Xd(:,i) = dout(:);
  Xq(:,i) = out(:);
end;
save animals_training_model_3 Xd Xq lbl;
exit;

  
