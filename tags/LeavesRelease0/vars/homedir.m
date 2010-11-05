function path = homedir

if ispc
    error('not defined under windows');
else
    path = '/cbcl/cbcl01/sharat/code/leaves/output';
end

return;
