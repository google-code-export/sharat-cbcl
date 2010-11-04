function path = resdir

% Base path under which to store job parameters and final job results.  These
% are generally small files that you'll want to keep permanently.

path = fullfile(homedir, 'work');

return;
