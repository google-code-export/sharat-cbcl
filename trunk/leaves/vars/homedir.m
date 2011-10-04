function path = homedir

if ispc
    error('not defined under windows');
else
    path = '/home/sharat/code/sharat-cbcl/leaves/output';
end

return;
