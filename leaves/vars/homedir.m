function path = homedir

if ispc
    error('not defined under windows');
else
    path = '/home/sharat/open-source/sharat-cbcl/leaves';
end

return;
