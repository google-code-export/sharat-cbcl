function out=select_c1_c2_c2b(ftr)
   load ~/animals/cidx;
   %load ~/animals/c1orgidx;
   c1 =c12vec(ftr{1});c1=c1(idx);
   fprintf('Length C1:%d\n',length(c1));
   
   load ~/animals/c2idx;
   %load ~/animals/cidx;
   c2     =ftr{2};
   c2     =c_generic(c2,1,1,length(c2));
   c2{1}  =imresize(c2{1},[16 16],'bicubic');
   c2rand =c2{1}(idx);
   fprintf('Length C2:%d\n',length(c2rand));
   
   c2     =c_generic(c2,12,15,1);
   c2     =c12vec(c2);
   fprintf('Length C2:%d\n',length(c2));
   
   c2b=ftr{3};
   fprintf('Length C2b:%d\n',length(c2b));
   out=[c2b(:);c1(:);c2rand(:)];
  %reduce resolution
%end function;
