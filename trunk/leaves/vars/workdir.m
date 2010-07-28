function path = workdir

% Base path under which to store the results of intermediate tasks.  This will
% generally reside on some kind of "scratch" storage that can be purged from
% time to time.

path = fullfile(homedir, 'work');

return;
