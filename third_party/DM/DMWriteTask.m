function DMWriteTask(jobDir, taskName, r, place)

% DMWriteTask - Create or overwrite a task result file "manually".
%
% TODO

%***********************************************************************************************************************

if nargin < 4, place = ''; end

permPath = fullfile(resdir , jobDir);
workPath = fullfile(workdir, jobDir);
permFilePath = fullfile(permPath, [taskName '.mat']);
workFilePath = fullfile(workPath, [taskName '.mat']);
separate = ~strcmp(permPath, workPath);

switch place
case ''

    if exist(permFilePath, 'file')
        save(permFilePath, '-struct', 'r');
    elseif separate && exist(workFilePath, 'file')
        save(workFilePath, '-struct', 'r');
    else
        error('file "%s.mat" does not exist', taskName);
    end

case 'p'

    if separate && exist(workFilePath, 'file')
        error('file "%s.mat" already exists in %s', taskName, workPath);
    end

    if ~exist(permPath, 'dir'), mkdir(permPath); end

    save(permFilePath, '-struct', 'r');

case 'w'

    if separate && exist(permFilePath, 'file')
        error('file "%s.mat" already exists in %s', taskName, permPath);
    end

    if ~exist(workPath, 'dir'), mkdir(workPath); end

    save(workFilePath, '-struct', 'r');

otherwise

    error 'invalid place';

end

return;
