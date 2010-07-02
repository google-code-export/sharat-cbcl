%------------------------------------------------------
%
%
%
%
%------------------------------------------------------
function html_tree(root,dirname)
   mkdir(dirname);
   fid = fopen(sprintf('%s/index.html',dirname),'w');
   %write headers
   fprintf(fid,'<html><body>\n');
   parse_tree(root,dirname,fid,0);
   fprintf(fid,'</body></html>');
   fclose(fid);
%end function html_tree

%------------------------------------------------
%
%
%------------------------------------------------
function token = parse_tree(root,dirname,fid,token)
  if(isempty(root.h))
    return;
  end;
  fprintf(fid,'<table border="1" cellspacing = 1><tr>\n');
  for i = 1:length(root.h)
    token = token+1;
    fprintf(fid,'<td align="top">\n');
    imgfile = sprintf('%d.gif',token);
    imwrite(imresize(root.h(i).img,1.5),sprintf('%s/%s',dirname,imgfile));
    fprintf(fid,'<div align="center"><img src="%s"></div>\n',imgfile);
    token = parse_tree(root.h(i),dirname,fid,token);
    fprintf(fid,'</td>\n');
  end;
  fprintf(fid,'</tr></table>\n');
%end function parse_tree
