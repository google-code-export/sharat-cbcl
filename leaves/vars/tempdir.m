function path = tempdir

% A path for temporary files.  Sometimes temporary files are used for
% communication between processes running on different machines.  Hence this
% directory should be located on a shared file system.

if ispc
    error('not defined under windows');
else
    path = fullfile(homedir, 'temp', getenv('USER'));
end

return;
