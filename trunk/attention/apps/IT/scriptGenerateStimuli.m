function scriptGenerateStimuli(trnSize)
load arraySettings array
imgHome='stimuli';
for i=1:size(array,1)
  cond=sscanf(array(i,1),'%d');
  stim1=sscanf(array(i,2:3),'%d');
  stim2=sscanf(array(i,4:5),'%d');
  stim3=sscanf(array(i,6:7),'%d');
  H=600;
  img=ones(H,H);
  R  =5.5*40;
  SZ =128;
  %position 1
  if(stim1>0)
	posx=round(H/2+R*cos(0)-SZ/2);
	posy=round(H/2+R*sin(0)-SZ/2);
	box=im2double(imread(fullfile(imgHome,sprintf('%d.png',stim1))));
	box=imresize(box,[SZ SZ],'bicubic');
	img(posy:posy+SZ-1,posx:posx+SZ-1)=box;
  end;
  if(stim2>0)
	posx=round(H/2+R*cos(pi/3)-SZ/2);
	posy=round(H/2-R*sin(pi/3)-SZ/2);
	box=im2double(imread(fullfile(imgHome,sprintf('%d.png',stim2))));
	box=imresize(box,[SZ SZ],'bicubic');
	img(posy:posy+SZ-1,posx:posx+SZ-1)=box;
  end;
  if(stim3>0)
	posx=round(H/2+R*cos(pi/3)-SZ/2);
	posy=round(H/2+R*sin(pi/3)-SZ/2);
	box=im2double(imread(fullfile(imgHome,sprintf('%d.png',stim3))));
	box=imresize(box,[SZ SZ],'bicubic');
	img(posy:posy+SZ-1,posx:posx+SZ-1)=box;
  end;
  imagesc(img);colormap('gray');drawnow;
  filename=fullfile('testing',sprintf('%s.png',array(i,:)));
  imwrite(img,filename);
  fprintf('%d:%d:%d:%d\n',cond,stim1,stim2,stim3);
end;
