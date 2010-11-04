function path = datadir

% Base path under which input data directories (such as image datasets) reside.
% Setting this path here lets you avoid using absolute paths throughout your
% code; you can instead specify paths relative to this path.  For example, the
% Caltech 101 dataset might be identified by "%datadir/cal101".

path = fullfile(homedir, 'data');

return;
