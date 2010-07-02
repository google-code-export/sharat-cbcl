clear all;
close all;
load for_sharat_all_stimulus_attention_conditions_used
array=for_sharat_all_stimulus_attention_conditions_used;
for i=1:size(array,1)
  x(i,:)=sprintf('%07d',array(i,:));
end;

for stim=1:16
  str=sprintf('0%02d0000',stim);
  x(end+1,:)=str;
  str=sprintf('000%02d00',stim);
  x(end+1,:)=str;
  str=sprintf('00000%02d',stim);
  x(end+1,:)=str;
end;
array=x;
keyboard;
