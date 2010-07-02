%------------------------------------------
%lists all the data files
%format:
%pathname,class,tag1,tag2...
%clear all;
close all;
load database;
fout=fopen('database.txt','w');

%-----------------------------
%filter database
for c=1:length(classes)
  DB=D{c};
  F=DB(1)
  nobj=[]
  cnt=1
  for i=1:length(DB)
	if(~isfield(DB(i).annotation,'object') | ...
       length(DB(i).annotation.object)<3)
	  continue;
	end;
	F(cnt)=DB(i);
	nobj(cnt)=length(DB(i).annotation.object);
	cnt=cnt+1;
  end;
  idx=randperm(length(F));
  D{c}=F(idx(1:min(300,length(idx))));
end;
keyboard;

for c=1:length(classes)
  DB=D{c};
OB  for i=1:length(DB)
	fprintf('Processing class:%d,item:%d of %d\n',c,i,length(DB));
	fprintf(fout,'%s,%s,%s',DB(i).annotation.folder,...
	                        DB(i).annotation.filename,classes{c});
	if(~isfield(DB(i).annotation,'object'))
	  fprintf(fout,'\n');
	  continue;
	end;
	for o=1:length(DB(i).annotation.object)
	  fprintf(fout,',%s',DB(i).annotation.object(o).name);
	end;
	fprintf(fout,'\n');
  end;
end;
fclose(fout);
