function r = DMReadTask(jobDir, taskName, mode, dflt)

% DMReadTask - Read the results of a completed task.
%
% TODO

%***********************************************************************************************************************

if nargin < 3, mode = 'req' ; end
if nargin < 4, dflt = struct; end

permFilePath = fullfile(resdir , jobDir, [taskName '.mat']);
workFilePath = fullfile(workdir, jobDir, [taskName '.mat']);
separate = ~strcmp(permFilePath, workFilePath);

if exist(permFilePath, 'file')
    filePath = permFilePath;
elseif separate && exist(workFilePath, 'file')
    filePath = workFilePath;
else
    filePath = '';
end

switch mode
case 'req'

    if isempty(filePath), error('file "%s.mat" does not exist', taskName); end
    r = load(filePath);

case 'opt'

    if isempty(filePath)
        r = dflt;
    else
        r = load(filePath);
    end

case 'exist'

    r = ~isempty(filePath);

end

return;
