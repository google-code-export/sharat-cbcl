function DMDispTasks(jobName, varargin)

% DMDispTasks - List all tasks for a job.
%
% TODO

%***********************************************************************************************************************

params = DMReadParams(jobName, varargin{:});

if isfield(params, 'tasks')
    tasks = params.tasks;
elseif isfield(params, 'jobFunc')
    tasks = DMJobFunc(params.jobFunc, 'tasks', true, params);
else
    error 'task list missing';
end

states = GetStates(jobName, tasks);

funcs = cell(1, numel(tasks));
for i = 1 : numel(tasks)
    if isfield(tasks{i}, 'func')
        funcs{i} = tasks{i}.func;
    else
        funcs{i} = params.jobFunc;
    end
    if isa(funcs{i}, 'function_handle')
        funcs{i} = func2str(funcs{i});
    end
    if isfield(tasks{i}, 'op')
        funcs{i} = [funcs{i} '>' tasks{i}.op];
    end
end

numLen   = floor(log10(numel(tasks))) + 1;
nameLen  = 0;
stateLen = 0;
funcLen  = 0;

for i = 1 : numel(tasks)
    nameLen  = max(nameLen , numel(tasks{i}.name));
    stateLen = max(stateLen, numel(states{i}    ));
    funcLen  = max(funcLen , numel(funcs{i}     ));
end

fprintf('\n');

for i = 1 : numel(tasks)

    fprintf('%-*u  %-*s  %-*s  %-*s ', ...
        numLen, i, nameLen, tasks{i}.name, stateLen, states{i}, funcLen, funcs{i});

    if isfield(tasks{i}, 'args')
        fprintf(' %s', DispArray(tasks{i}.args));
    end

    if isfield(tasks{i}, 'depends')
        for j = 1 : numel(tasks{i}.depends)
            fprintf(' %s', tasks{i}.depends{j});
        end
    end

    fprintf('\n');

end

fprintf('\n');

return;

%***********************************************************************************************************************

function states = GetStates(jobName, tasks)

if ischar(jobName) && isempty(strmatch('@', jobName))
    permPath = fullfile(resdir , jobName);
    workPath = fullfile(workdir, jobName);
    separate = ~strcmp(permPath, workPath);
    files = dir(permPath);
    if separate, files = [files ; dir(workPath)]; end
    fileNames = {files.name};
else
    fileNames = {};
end

names  = cell(1, numel(tasks));
states = cell(1, numel(tasks));

for i = 1 : numel(tasks)
    names{i} = tasks{i}.name;
    if ismember([tasks{i}.name '.mat'], fileNames)
        states{i} = 'complete';
    else
        states{i} = '-';
    end
end

for i = 1 : numel(tasks)
    if ~strcmp(states{i}, 'complete')
        if isfield(tasks{i}, 'depends')
            [dummy, depends] = ismember(tasks{i}.depends, names);
        else
            depends = [];
        end
        if all(strcmp(states(depends), 'complete'))
            states{i} = 'ready';
        end
    end
end

return;

%***********************************************************************************************************************

function s = DispArray(a)

if ndims(a) > 2
    s = '???';
elseif isnumeric(a) || islogical(a)
    s = mat2str(a);
elseif ischar(a) && (size(a, 1) == 1)
    s = ['''', a, ''''];
elseif iscell(a)
    s = '{';
    for i = 1 : size(a, 1)
        if i > 1, s = [s '; ']; end
        for j = 1 : size(a, 2)
            if j > 1, s = [s ' ']; end
            s = [s, DispArray(a{i, j})];
        end
    end
    s = [s '}'];
elseif isstruct(a) && isscalar(a)
    names = fieldnames (a);
    vals  = struct2cell(a);
    s = '[';
    for i = 1 : numel(names)
        if i > 1, s = [s ', ']; end
        s = [s, names{i}, '=', DispArray(vals{i})];
    end
    s = [s ']'];
else
    s = '???';
end

return;
