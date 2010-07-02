function send_mail(msg)
  system(sprintf('echo "%s" > __tmp_msg',msg));
  system(sprintf('mail -s status sharat < __tmp_msg'));
%end function
