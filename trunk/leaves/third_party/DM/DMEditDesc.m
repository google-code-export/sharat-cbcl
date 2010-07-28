function DMEditDesc(varargin)

% DMEditDesc -
%
% TODO

%***********************************************************************************************************************

jobDirs = {};
for i = 1 : nargin
    dirs = DMFindJobs(varargin{i});
    for j = 1 : numel(dirs)
        if ~ismember(dirs{j}, jobDirs), jobDirs{end + 1} = dirs{j}; end
    end
end
n = numel(jobDirs);
if n == 0, return; end
if n > 12, error('cannot edit more than %u jobs', 12); end

ps    = cell(1, n);
descs = cell(1, n);
for i = 1 : n
    ps{i} = DMReadTask(jobDirs{i}, 'params');
    if isfield(ps{i}, 'desc')
        descs{i} = ps{i}.desc;
    else
        descs{i} = '';
    end
end

descs = inputdlg(jobDirs, 'DMEditDesc', 1, descs, 'on');
if isempty(descs), return; end

for i = 1 : n
    ps{i}.desc = descs{i};
    DMWriteTask(jobDirs{i}, 'params', ps{i});
end

return;
