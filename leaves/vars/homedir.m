function path = homedir

if ispc
    error('not defined under windows');
else
    path = '/cbcl/scratch01/sharat/LeavesData';
end

return;
