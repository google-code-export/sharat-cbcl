function DMRunJob(varargin)

% DMRunJob - Run a job on a machine.
%
% TODO

%***********************************************************************************************************************
% Global variables.
%***********************************************************************************************************************

JobDir       = [];
PermPath     = [];
WorkPath     = [];
Separate     = [];
StepFilePath = [];
HostName     = [];
CPU          = [];
ErrFilePath  = [];

Params       = [];
Tasks        = [];

LogPath      = [];
LogFileName  = [];
LogFilePath  = [];
LockFilePath = [];
RunFilePath  = [];

ResultStages = [];
Results      = [];
Stopped      = [];

Main(varargin{:});

%***********************************************************************************************************************
% Startup and shutdown routines (unserialized).
%***********************************************************************************************************************

function Main(jobDir, buildNames, varargin)

if nargin < 2, buildNames = {}; end

if nargin < 3
    options = struct;
elseif nargin == 3
    options = varargin{1};
else
    options = struct(varargin{:});
end

if ischar(buildNames)
    if isempty(buildNames) || strcmp(buildNames, 'all')
        buildNames = {};
    else
        buildNames = {buildNames};
    end
end

if ~isfield(options, 'buildDepends'), options.buildDepends = true ; end
if ~isfield(options, 'cpu'         ), options.cpu          = false; end
if ~isfield(options, 'logFileName' ), options.logFileName  = ''   ; end
if ~isfield(options, 'runFilePath' ), options.runFilePath  = ''   ; end
if ~isfield(options, 'stepFilePath'), options.stepFilePath = ''   ; end

extra = rmfield(options, {'buildDepends', 'cpu', 'logFileName', 'runFilePath', 'stepFilePath'});

JobDir       = jobDir;
PermPath     = fullfile(resdir , jobDir);
WorkPath     = fullfile(workdir, jobDir);
Separate     = ~strcmp(PermPath, WorkPath);
StepFilePath = options.stepFilePath;
HostName     = GLHostName;
CPU          = options.cpu;
ErrFilePath  = fullfile(PermPath, 'error.mat');

Params = DMReadTask(jobDir, 'params');

GetTaskList(buildNames, options.buildDepends, extra);

if ~exist(PermPath, 'dir'), mkdir(PermPath); end
if Separate && ~exist(WorkPath, 'dir'), mkdir(WorkPath); end
disp('starting log')
StartLog(options.logFileName, options.runFilePath);

ResultStages = repmat(-1      , 1, numel(Tasks));
Results      = repmat({struct}, 1, numel(Tasks));
Stopped      = false;

JobPrintf('starting job\n');

err = '';

try
    BuildJob;
catch
    err = lasterr;
    if isempty(err), err = 'unknown error'; end
end

if isempty(err)
    if Stopped
        JobPrintf('stopped\n');
    else
        JobPrintf('all tasks complete\n');
    end
else
    JobPrintf('%s\n', err);
end

StopLog(~isempty(options.runFilePath));

if ~isempty(err), error 'job terminated'; end

end

%***********************************************************************************************************************

function GetTaskList(buildNames, buildDepends, extra)

if isfield(Params, 'tasks')
    jobTasks = Params.tasks;
elseif isfield(Params, 'jobFunc')
    jobTasks = DMJobFunc(Params.jobFunc, 'tasks', true, Params);
    if isempty(jobTasks), error 'unable to retrieve task list'; end
else
    error 'task list missing';
end

for i = 1 : numel(jobTasks)

    task = struct;

    task.taskNo = i;

    taskInfo = jobTasks{i};

    task.name = taskInfo.name;
    if regexp(task.name, '[._]', 'once')
        error('task "%s": task name cannot contain [._]', task.name);
    end
    if ismember(task.name, {'all', 'DMRunJob', 'logs', 'params'})
        error('task "%s": this task name is reserved', task.name);
    end

    if isfield(taskInfo, 'args')
        if ~isstruct(taskInfo.args) || ~isscalar(taskInfo.args)
            error('task "%s": args must be a structure', task.name);
        end
        task.args = taskInfo.args;
    else
        task.args = struct;
    end

    names = fieldnames (task.args);
    args  = struct2cell(task.args);
    for j = 1 : numel(names)
        if ismember(names{j}, {'cpu', 'itemNo', 'items'})
            error('task "%s": argument name "%s" is reserved', task.name, names{j});
        end
        if ischar(args{j}) && ~isempty(regexp(args{j}, '^%..*%$', 'once')) && isvarname(args{j}(2 : end - 1))
            if ~isfield(extra, args{j}(2 : end - 1))
                error('task "%s": option "%s" not passed', task.name, args{j}(2 : end - 1));
            end
            task.args.(names{j}) = extra.(args{j}(2 : end - 1));
        end
    end

    if isfield(taskInfo, 'depends')
        task.depends = taskInfo.depends;
    else
        task.depends = {};
    end

    if isfield(taskInfo, 'perm')
        task.perm = taskInfo.perm;
    else
        task.perm = false;
    end

    if isfield(taskInfo, 'keep')
        task.keep = taskInfo.keep;
        if task.perm && ~task.keep
            error('task "%s": permanent tasks must be kept', task.name);
        end
    else
        task.keep = true;
    end

    if isfield(taskInfo, 'readOnly')
        task.readOnly = taskInfo.readOnly;
    else
        task.readOnly = false;
    end

    if isfield(taskInfo, 'func')

        if isfield(taskInfo, 'sub')
            if isempty(fieldnames(task.args))
                funcInfo = DMJobFunc(taskInfo.func, 'func', true, Params, taskInfo.sub);
            else
                funcInfo = DMJobFunc(taskInfo.func, 'func', true, Params, taskInfo.sub, task.args);
            end
            if isempty(funcInfo)
                error('task "%s": subfunction "%s" not found', task.name, taskInfo.sub);
            end
        else
            if isempty(fieldnames(task.args))
                funcInfo = feval(taskInfo.func, Params);
            else
                funcInfo = feval(taskInfo.func, Params, task.args);
            end
        end

        names = fieldnames(funcInfo);
        for j = 1 : numel(names)
            if ~isfield(taskInfo, names{j})
                taskInfo.(names{j}) = funcInfo.(names{j});
            end
        end

    elseif isfield(taskInfo, 'sub')

        error('task "%s": sub specified without func', task.name);

    end

    task.methods = GLCopyFields(struct, taskInfo, ...
        {'build', 'start', 'binit', 'item', 'bdone', 'batch', 'combine'});

    if isfield(task.methods, 'build')
        if any(isfield(task.methods, {'start', 'binit', 'item', 'bdone', 'batch', 'combine'}))
            error('task "%s": methods are inconsistent', task.name);
        end
        task.batch      = false;
        task.singleCall = false;
    elseif isfield(task.methods, 'item')
        if any(isfield(task.methods, {'build', 'batch'}))
            error('task "%s": methods are inconsistent', task.name);
        end
        task.batch      = true;
        task.singleCall = false;
    elseif isfield(task.methods, 'batch')
        if any(isfield(task.methods, {'build', 'item'}))
            error('task "%s": methods are inconsistent', task.name);
        end
        task.batch      = true;
        task.singleCall = true;
    else
        error('task "%s": no methods defined', task.name);
    end

    if isfield(taskInfo, 'dimension')
        if ~task.batch
            error('task "%s": dimension is only meaningful for batch tasks', task.name);
        end
        task.dimension = taskInfo.dimension;
    else
        task.dimension = 1;
    end

    if isfield(taskInfo, 'holdTime')
        if task.batch
            error('task "%s": holdTime is not meaningful for batch tasks', task.name);
        end
        task.holdTime = taskInfo.holdTime;
    else
        task.holdTime = envvar('DMDfltHoldTime', 60 * 60);
    end

    if isfield(taskInfo, 'startHoldTime')
        if ~task.batch
            error('task "%s": startHoldTime is only meaningful for batch tasks', task.name);
        end
        task.startHoldTime = taskInfo.startHoldTime;
    else
        task.startHoldTime = envvar('DMDfltHoldTime', 60 * 60);
    end

    if isfield(taskInfo, 'batchHoldTime')
        if ~task.batch
            error('task "%s": batchHoldTime is only meaningful for batch tasks', task.name);
        end
        task.batchHoldTime = taskInfo.batchHoldTime;
    else
        task.batchHoldTime = envvar('DMDfltHoldTime', 60 * 60);
    end

    if isfield(taskInfo, 'combineHoldTime')
        if ~task.batch
            error('task "%s": combineHoldTime is only meaningful for batch tasks', task.name);
        end
        task.holdTime = taskInfo.combineHoldTime;
    else
        task.holdTime = envvar('DMDfltHoldTime', 60 * 60);
    end

    task.dependNos = zeros(1, numel(task.depends));
    task.parentNos = [];
    task.childNos  = [];
    task.target    = false;

    if i == 1
        Tasks = task;
    else
        Tasks(i) = task;
    end

end

taskNames = {Tasks.name};
if numel(unique(taskNames)) ~= numel(Tasks), error 'task names must be unique'; end

for i = 1 : numel(Tasks)
    for j = 1 : numel(Tasks(i).depends)
        if isempty(Tasks(i).depends{j})
            Tasks(i).dependNos(j) = 0;
        else
            parentNo = find(strcmp(taskNames, Tasks(i).depends{j}), 1);
            if isempty(parentNo)
                error('task "%s": dependency "%s" not found', Tasks(i).name, Tasks(i).depends{j});
            end
            Tasks(i).dependNos(j      ) = parentNo;
            Tasks(i).parentNos(end + 1) = parentNo;
            Tasks(parentNo).childNos(end + 1) = i;
        end
    end
end

for i = 1 : numel(Tasks)
    if ~Tasks(i).keep && isempty(Tasks(i).childNos)
        error('task "%s": must keep its results because it has no children', Tasks(i).name);
    end
end

if isempty(buildNames)
    for i = 1 : numel(Tasks)
        Tasks(i).target = Tasks(i).keep;
    end
else
    for i = 1 : numel(buildNames)
        taskNo = find(strcmp(taskNames, buildNames{i}), 1);
        if isempty(taskNo), error('task "%s" not found', buildNames{i}); end
        Tasks(taskNo).target = true;
        Tasks(taskNo).keep   = true;
    end
end

if ~buildDepends
    for i = 1 : numel(Tasks)
        if ~Tasks(i).target, Tasks(i).readOnly = true; end
    end
end

end

%***********************************************************************************************************************

function StartLog(logFileName, runFilePath)

LogPath = fullfile(WorkPath, 'logs');

if isempty(logFileName)

    time    = datestr(now, 30);
    attempt = 1;

    while true

        LogFileName = [HostName '_' time];
        if attempt > 1, LogFileName = [LogFileName '_' sprintf('%u', attempt)]; end

        LogFilePath  = fullfile(LogPath, [LogFileName '.log' ]);
        LockFilePath = fullfile(LogPath, [LogFileName '.lock']);
        RunFilePath  = fullfile(LogPath, [LogFileName '.run' ]);

        if ~exist(LogFilePath, 'file') && ~exist(LockFilePath, 'file') && ~exist(RunFilePath, 'file'), break; end

        attempt = attempt + 1;

    end

    if ~exist(LogPath, 'dir'), mkdir(LogPath); end

    fid = fopen(LogFilePath, 'w');
    fclose(fid);

    fid = fopen(LockFilePath, 'w');
    fclose(fid);

    fid = fopen(RunFilePath, 'w');
    fclose(fid);

else

    LogFileName  = logFileName;
    LogFilePath  = fullfile(LogPath, [logFileName '.log' ]);
    LockFilePath = fullfile(LogPath, [logFileName '.lock']);
    RunFilePath  = runFilePath;

    if exist(LogFilePath, 'file') || exist(LockFilePath, 'file')
        error('log file name "%s" is already in use', logFileName);
    end

    if ~exist(RunFilePath, 'file')
        error('run file "%s" does not exist', RunFilePath);
    end

    if ~exist(LogPath, 'dir'), mkdir(LogPath); end

    fid = fopen(LogFilePath, 'w');
    fclose(fid);

    fid = fopen(LockFilePath, 'w');
    fclose(fid);

end

diary(LogFilePath);

end

%***********************************************************************************************************************

function StopLog(keepRun)

diary off;

if exist(LockFilePath, 'file'), delete(LockFilePath); end

if ~keepRun
    if exist(RunFilePath, 'file'), delete(RunFilePath); end
end

end

%***********************************************************************************************************************
% Main loop (partly serialized).
%***********************************************************************************************************************

function BuildJob

holdSleepTime = envvar('DMHoldSleepTime', 60);

state      = NewState(4);
waitStatus = struct;
quit       = false;
err        = '';

while true

    discardedTask = 0;
    deletedTasks  = [];

    if exist(ErrFilePath, 'file')
        quit = true;
    elseif ~exist(RunFilePath, 'file')
        quit = true;
        Stopped = true;
    end

    LockJob;

    if state.stage ~= 4
        if ReleaseHold(task, state) && ~quit
            WriteResult(task, state, result);
        else
            discardedTask = task.taskNo;
        end
    end

    if ~quit
        [states, err] = ReadTaskStates;
        if ~isempty(err), quit = true; end
    end

    if ~quit
        [ans, buildable, err] = FindNeededTasks(states, [Tasks.target], true);
        if ~isempty(err), quit = true; end
    end

    if ~quit

        needed = FindNeededTasks(states, [Tasks.keep], false);
        deletedTasks = find(~needed & ([states.stage] == 5));
        for i = 1 : numel(deletedTasks)
            DeleteResult(Tasks(deletedTasks(i)));
        end

        if any(buildable)
            taskNo = find(buildable & ([states.stage] ~= 4), 1);
            if isempty(taskNo)
                state = NewState(4);
            else
                task  = Tasks (taskNo);
                state = states(taskNo);
                PlaceHold(task, state);
            end
        else
            quit = true;
        end

    end

    UnlockJob;

    if discardedTask ~= 0
        TaskPrintf('discarded\n', Tasks(discardedTask).name);
    end

    for i = 1 : numel(deletedTasks)
        TaskPrintf('deleted result\n', Tasks(deletedTasks(i)).name);
    end

    if quit
        WriteState(struct, NewState(5));
        break;
    end

    if state.stage == 4
        waitStatus = WaitMsg(waitStatus);
        DMSleep(holdSleepTime);
    else
        waitStatus = struct;
        WriteState(task, state);
        try
            [result, state] = BuildTask(task, state);
        catch
            err = lasterr;
            if isempty(err)
                err = 'unknown error';
            elseif ~isempty(strfind(err, '@ERROR@'))
                err = '';
            end
            quit = true;
        end
    end

end

if ~isempty(err), error(err); end

end

%***********************************************************************************************************************

function status = WaitMsg(status)

time = clock;

if ~isfield(status, 'num') || (status.num == 0)

    WriteState(struct, NewState(4));

    JobPrintf('waiting for other processors\n');

    status.num  = 1;
    status.time = time;

else

    waitTimes = envvar('DMWaitMsgTimes', [5 15 60] * 60);
    cumTimes  = cumsum(waitTimes);

    if status.num <= numel(waitTimes)
        nextTime = cumTimes(status.num);
    else
        nextTime = cumTimes(end) + waitTimes(end) * (status.num - numel(waitTimes));
    end

    if etime(time, status.time) > nextTime

        JobPrintf('waiting for other processors\n');

        status.num = status.num + 1;

    end

end

end

%***********************************************************************************************************************

function WriteState(task, state)

if isempty(StepFilePath), return; end

switch state.stage
case 0, t = task.taskNo; b = 0            ; desc = task.name;
case 1, t = task.taskNo; b = 0            ; desc = sprintf('%s (starting)', task.name);
case 2, t = task.taskNo; b = state.batchNo; desc = sprintf('%s (%u/%u)', task.name, state.batchNo, state.numBatches);
case 3, t = task.taskNo; b = 999999       ; desc = sprintf('%s (combining)', task.name);
case 4, t = 999998     ; b = 0            ; desc = 'waiting';
case 5, t = 999999     ; b = 0            ; desc = '';
end

fid = fopen(StepFilePath, 'w');
fprintf(fid, '%s\n', desc);
fprintf(fid, '%06u%06u\n', t, b);
fclose(fid);

end

%***********************************************************************************************************************
% Routines that execute individual task stages (unserialized).
%***********************************************************************************************************************

function [result, state] = BuildTask(task, state)

switch state.stage
case 0, result          = BuildSingle (task, state);
case 1, [result, state] = BuildStart  (task, state);
case 2, result          = BuildBatch  (task, state);
case 3, result          = BuildCombine(task, state);
end

end

%***********************************************************************************************************************

function result = BuildSingle(task, state)

CachePurge(task);

TaskPrintf('starting\n', task.name);

[cpu, ans, result] = TaskFunc(task, 'build');
if isempty(result), error 'build call not handled'; end

TaskPrintf('saving result\n', task.name);

CacheStore(task, state, result);

WriteCPU(task, cpu);

end

%***********************************************************************************************************************

function [result, state] = BuildStart(task, state)

CachePurge(task);

TaskPrintf('initializing batch task\n', task.name);

[cpu, ans, result] = TaskFunc(task, 'start');
if isempty(result), error 'start call not handled'; end

if isfield(result, 'items'), error 'start call cannot return a field called "items"'; end

result.cpu = cpu;

state.numBatches = ceil(result.count / result.batchSize);

TaskPrintf('initialization complete\n', task.name);

CacheStore(task, state, result);

end

%***********************************************************************************************************************

function result = BuildBatch(task, state)

prevState = NewState(state, 'stage', 1);

CachePurge(task, prevState);

current = CacheRead(task, prevState);
current = rmfield(current, 'cpu');

startNo  = (state.batchNo - 1) * current.batchSize + 1;
numItems = min(current.batchSize, current.count - startNo + 1);
stopped  = false;

TaskPrintf('starting batch %u/%u (%u-%u)\n', ...
    task.name, state.batchNo, state.numBatches, startNo, startNo + numItems - 1);

if task.singleCall

    current.itemNo = startNo : startNo + numItems - 1;
    [totalCPU, ans, items] = TaskFunc(task, 'batch', current);
    if isempty(items), error 'batch call not handled'; end

else

    totalCPU = 0;

    current.itemNo = startNo : startNo + numItems - 1;
    [cpu, ans, init] = TaskFunc(task, 'binit', current);
    totalCPU = totalCPU + cpu;

    if isempty(init)
        init = false;
    else
        current = init;
        init = true;
    end

    items      = struct;
    numColumns = 0;

    for i = 1 : numItems

        if ~exist(RunFilePath, 'file')
            stopped = true;
            break;
        end

        itemNo = startNo + i - 1;

        current.itemNo = itemNo;
        [cpu, time, item] = TaskFunc(task, 'item', current);
        if isempty(item), error 'item call not handled'; end

        load = round(cpu / time * 100);

        if isfield(item, 'desc') && ~isempty(item.desc)
            desc = item.desc;
        else
            desc = 'done';
        end

        DMPrintf('%u/%u: %s (%.1fs @%u%%)\n', itemNo, current.count, desc, time, load);

        if i == 1

            varNames = fieldnames(item)';

            j = find(strcmp(varNames, 'desc'), 1);
            if ~isempty(j), varNames(j) = []; end

            numVars = numel(varNames);
            dims    = zeros(1, numVars);
            colons  = cell(1, numVars);
            for j = 1 : numVars
                [dims(j), colons{j}, initialSize] = ...
                    GetVarInfo(task.dimension, varNames{j}, size(item.(varNames{j})), 0);
                items.(varNames{j}) = PreAllocate(class(item.(varNames{j})), initialSize);
            end

        end

        itemColumns = size(item.(varNames{1}), dims(1) + 1);

        for j = 1 : numVars

            if (j ~= 1) && (size(item.(varNames{j}), dims(j) + 1) ~= itemColumns)
                error('item %u, variable "%s": size of last dimension does not match', itemNo, varNames{j});
            end

            if itemColumns ~= 0
                items.(varNames{j})(colons{j}{:}, numColumns + 1 : numColumns + itemColumns) = item.(varNames{j});
            end

        end

        numColumns = numColumns + itemColumns;

        totalCPU = totalCPU + cpu;

    end

    if init
        current.itemNo = startNo : startNo + numItems - 1;
        [cpu, ans] = TaskFunc(task, 'bdone', current);
        totalCPU = totalCPU + cpu;
    end

end

result = items;

result.cpu = totalCPU;

if stopped
    TaskPrintf('stopped in batch %u\n', task.name, state.batchNo);
else
    TaskPrintf('saving batch %u\n', task.name, state.batchNo);
end

end

%***********************************************************************************************************************

function result = BuildCombine(task, state)

prevState = NewState(state, 'stage', 1);

CachePurge(task, prevState);

current = CacheRead(task, prevState);

totalCPU = current.cpu;
current  = rmfield(current, 'cpu');

numItems = state.numBatches;

TaskPrintf('starting combining batches\n', task.name);

items      = struct;
numColumns = 0;

for i = 1 : numItems

    item = ReadResult(task, NewState(state, 'stage', 2, 'batchNo', i));

    if i == 1

        varNames = fieldnames(item)';

        j = find(strcmp(varNames, 'cpu'), 1);
        if ~isempty(j), varNames(j) = []; end

        numVars = numel(varNames);
        dims    = zeros(1, numVars);
        colons  = cell(1, numVars);
        for j = 1 : numVars
            [dims(j), colons{j}, initialSize] = ...
                GetVarInfo(task.dimension, varNames{j}, size(item.(varNames{j})), current.count);
            items.(varNames{j}) = PreAllocate(class(item.(varNames{j})), initialSize);
        end

    end

    itemColumns = size(item.(varNames{1}), dims(1) + 1);

    for j = 1 : numVars

        if (j ~= 1) && (size(item.(varNames{j}), dims(j) + 1) ~= itemColumns)
            error('batch %u, variable "%s": size of last dimension does not match', i, varNames{j});
        end

        if itemColumns ~= 0
            items.(varNames{j})(colons{j}{:}, numColumns + 1 : numColumns + itemColumns) = item.(varNames{j});
        end

    end

    numColumns = numColumns + itemColumns;

    totalCPU = totalCPU + item.cpu;

end

if numColumns < current.count
    for j = 1 : numVars
        items.(varNames{j}) = items.(varNames{j})(colons{j}{:}, 1:numColumns);
    end
end

current.items = items;

[cpu, ans, result] = TaskFunc(task, 'combine', current);
if isempty(result), result = items; end

totalCPU = totalCPU + cpu;

TaskPrintf('saving result\n', task.name);

CacheStore(task, state, result);

WriteCPU(task, totalCPU);

end

%***********************************************************************************************************************

function [dim, colons, initialSize] = GetVarInfo(dimensions, varName, itemSize, initialCount)

if isstruct(dimensions)
    if isfield(dimensions, varName)
        dim = dimensions.(varName);
    elseif isfield(dimensions, 'default')
        dim = dimensions.default;
    else
        dim = 1;
    end
else
    dim = dimensions;
end

colons = repmat({':'}, 1, dim);

if dim == 0
    initialSize = [initialCount 1];
else
    itemSize(end + 1 : dim) = 1;
    initialSize = [itemSize(1 : dim) initialCount];
end

end

%***********************************************************************************************************************

function array = PreAllocate(class, size)

if strcmp(class, 'cell')
    array = cell(size);
else
    array = repmat(feval(class, 0), size);
end

end

%***********************************************************************************************************************

function [cpu, time, varargout] = TaskFunc(task, mode, args)

if nargin < 3, args = task.args; end

depends = cell(1, numel(task.depends));

for i = 1 : numel(task.depends)
    if task.dependNos(i) == 0
        depends{i} = struct;
    else
        depends{i} = CacheRead(Tasks(task.dependNos(i)), NewState(5));
    end
end

nout = nargout - 2;

cpu  = cputime;
time = clock;

if isfield(task.methods, mode)

    if ~task.batch && isempty(fieldnames(args))
        [varargout{1 : nout}] = feval(task.methods.(mode), Params, depends{:});
    else
        [varargout{1 : nout}] = feval(task.methods.(mode), Params, args, depends{:});
    end

    if (nout >= 1) && isstruct(varargout{1}) && isfield(varargout{1}, 'error') && ~isempty(varargout{1}.error)
        if ~exist(ErrFilePath, 'file')
            err = struct;
            err.msg = varargout{1}.error;
            save(ErrFilePath, '-struct', 'err');
        end
        error('@ERROR@');
    end

    if (nout >= 1) && isstruct(varargout{1}) && isfield(varargout{1}, 'cpu')
        error 'cannot return a field called "cpu"';
    end

else

    [varargout{1 : nout}] = deal([]);

end

cpu  = cputime - cpu;
time = etime(clock, time);

end

%***********************************************************************************************************************

function WriteCPU(task, cpu)

if ~CPU, return; end

fid = fopen(fullfile(LogPath, sprintf('%04u_%s.cpu', task.taskNo, task.name)), 'w');

fwrite(fid, sprintf('%f', cpu));

fclose(fid);

end

%***********************************************************************************************************************
% Routines for managing results being kept in memory (unserialized).
%***********************************************************************************************************************

function CachePurge(task, prevState)

if nargin < 2
    prevTaskNo = 0;
else
    prevTaskNo = task.taskNo;
end

for i = 1 : numel(Tasks)

    if i == prevTaskNo
        desiredStage = prevState.stage;
    elseif ismember(i, task.parentNos)
        desiredStage = 5;
    else
        desiredStage = -1;
    end

    if ResultStages(i) ~= desiredStage
        ResultStages(i) = -1;
        Results     {i} = struct;
    end

end

end

%***********************************************************************************************************************

function result = CacheRead(task, state)

if ResultStages(task.taskNo) == state.stage
    result = Results{task.taskNo};
else
    result = ReadResult(task, state);
    CacheStore(task, state, result);
end

end

%***********************************************************************************************************************

function CacheStore(task, state, result)

switch state.stage
case {0, 3, 5}, stage = 5;
case 1        , stage = 1;
end

ResultStages(task.taskNo) = stage;
Results     {task.taskNo} = result;

end

%***********************************************************************************************************************

function result = ReadResult(task, state)

result = load(MatFilePath(task, state));

end

%***********************************************************************************************************************
% Miscellaneous (unserialized).
%***********************************************************************************************************************

function JobPrintf(format, varargin)

DMPrintf(['%s, %s: %s: ' format], HostName, datestr(clock, 31), JobDir, varargin{:});

end

%***********************************************************************************************************************

function TaskPrintf(format, taskName, varargin)

DMPrintf(['%s, %s: %s, %s: ' format], HostName, datestr(clock, 31), JobDir, taskName, varargin{:});

end

%***********************************************************************************************************************
% Synchronization routines (serialized).
%***********************************************************************************************************************

function LockJob

filePath = fullfile(WorkPath, 'DMRunJob.lock');

while ~DMCreateLockFile(filePath, LockFilePath)

    DMSleep(envvar('DMLockSleepTime', 1));

end

end

%***********************************************************************************************************************

function UnlockJob

delete(fullfile(WorkPath, 'DMRunJob.lock'));

end

%***********************************************************************************************************************

function [states, err] = ReadTaskStates

files = dir(PermPath);
if Separate, files = [files ; dir(WorkPath)]; end

logFiles = dir(fullfile(WorkPath, 'logs', '*.log'));
time     = clock;

sortNames = cell(1, numel(files));

for i = 1 : numel(files)

    j = regexp(files(i).name, '[._]', 'once');
    if isempty(j), j = numel(files(i).name) + 1; end
    taskName = files(i).name(1 : j - 1);
    rest     = files(i).name(j : end  );

    if files(i).isdir
        type = 7;
    elseif regexp(rest, '^_000000_.+\.hold$')
        type = 1;
    elseif regexp(rest, '^_000000_\d{6}\.mat$')
        type = 2;
    elseif regexp(rest, '^_\d{6}_.+\.hold$')
        type = 3;
    elseif regexp(rest, '^_\d{6}\.mat$')
        type = 4;
    elseif regexp(rest, '^_.+\.hold$')
        type = 5;
    elseif regexp(rest, '^\.mat$')
        type = 6;
    else
        type = 7;
    end

    files(i).type = type;

    sortNames{i} = [taskName '_' num2str(type) rest];

end

[ans, indexes] = sort(sortNames);
files = files(indexes);

states = repmat(NewState, 1, numel(Tasks));

for i = 1 : numel(Tasks)
    if Tasks(i).batch, states(i) = NewState(1); end
end

taskNames = {Tasks.name};
taskName  = '';
taskNo    = [];

for i = 1 : numel(files) + 1

    if i <= numel(files)
        j = regexp(files(i).name, '[._]', 'once');
        if isempty(j), j = numel(files(i).name) + 1; end
        newTaskName = files(i).name(1 : j - 1);
        rest        = files(i).name(j : end  );
    else
        newTaskName = '.';
    end

    if ~strcmp(newTaskName, taskName)

        if ~isempty(taskNo)

            if stage == 2
                [ans, b] = min(batches);
                switch batches(b)
                case 0   , stage = 2; batchNo = b; logFileName = '';
                case 0.5 , stage = 2; batchNo = b; logFileName = batchLogFileName;
                case 4   , stage = 4; batchNo = 0; logFileName = '';
                otherwise, stage = 3; batchNo = 0; logFileName = '';
                end
            end

            states(taskNo).stage       = stage;
            states(taskNo).numBatches  = numBatches;
            states(taskNo).batchNo     = batchNo;
            states(taskNo).logFileName = logFileName;

        end

        if strcmp(newTaskName, '.'), break; end

        taskName = newTaskName;
        taskNo   = find(strcmp(taskNames, taskName), 1);

        if ~isempty(taskNo)
            firstFile   = true;
            types       = false(1, 6);
            stage       = states(taskNo).stage;
            numBatches  = 0;
            batchNo     = 0;
            logFileName = '';
        end

    end

    if isempty(taskNo), continue; end

    if firstFile
        firstFile = false;
    elseif strcmp(files(i).name, files(i - 1).name)
        err = sprintf('file "%s": appears twice', files(i).name);
        return;
    end

    if (files(i).type <= 4) && ~Tasks(taskNo).batch
        err = sprintf('file "%s": can only exist for batch tasks', files(i).name);
        return;
    end

    switch files(i).type
    case 1

        if types(1)
            err = sprintf('file "%s": should not be present', files(i).name);
            return;
        end

        fn = rest(9 : end - 5);

        if IsHoldCurrent(fn, logFiles, time, Tasks(taskNo).startHoldTime)
            stage = 4;
        else
            stage       = 1;
            logFileName = fn;
        end

    case 2

        if any(types([1 2]))
            err = sprintf('file "%s": should not be present', files(i).name);
            return;
        end

        stage      = 2;
        numBatches = str2double(rest(9:14));

        batches          = zeros(1, numBatches);
        batchLogFileName = '';

    case 3

        if ~types(2)
            err = sprintf('file "%s": should not be present', files(i).name);
            return;
        end

        b  = str2double(rest(2:7));
        fn = rest(9 : end - 5);

        if batches(b) ~= 0
            err = sprintf('file "%s": should not be present', files(i).name);
            return;
        end

        if IsHoldCurrent(fn, logFiles, time, Tasks(taskNo).batchHoldTime)
            batches(b) = 4;
        else
            batches(b) = 0.5;
            if isempty(batchLogFileName), batchLogFileName = fn; end
        end

    case 4

        if ~types(2)
            err = sprintf('file "%s": should not be present', files(i).name);
            return;
        end

        b = str2double(rest(2:7));

        if batches(b) ~= 0
            err = sprintf('file "%s": should not be present', files(i).name);
            return;
        end

        batches(b) = 5;

    case 5

        if Tasks(taskNo).batch && (~types(2) || types(3))
            err = sprintf('file "%s": should not be present', files(i).name);
            return;
        end

        fn = rest(2 : end - 5);

        if IsHoldCurrent(fn, logFiles, time, Tasks(taskNo).holdTime)
            stage = 4;
        elseif Tasks(taskNo).batch
            stage       = 3;
            logFileName = fn;
        else
            stage       = 0;
            logFileName = fn;
        end

    case 6

        if any(types([1 2 3 4 5]))
            err = sprintf('file "%s": should not be present', files(i).name);
            return;
        end

        stage = 5;

    otherwise

        err = sprintf('file "%s": invalid file', files(i).name);
        return;

    end

    types(files(i).type) = true;

end

err = '';

end

%***********************************************************************************************************************

function current = IsHoldCurrent(logFileName, logFiles, time, holdTime)

logFileName = [logFileName '.log'];

for i = 1 : numel(logFiles)
    if strcmp(logFiles(i).name, logFileName)
        current = (etime(time, datevec(logFiles(i).date)) <= holdTime);
        return;
    end
end

current = false;

end

%***********************************************************************************************************************

function [needed, buildable, err] = FindNeededTasks(states, target, checkRO)

needed    = target;
buildable = false(1, numel(Tasks));

check = target;

while true

    i = find(check, 1);
    if isempty(i), break; end
    check(i) = false;

    if states(i).stage == 5, continue; end

    if checkRO && Tasks(i).readOnly
        err = sprintf('task "%s": read-only task does not exist', Tasks(i).name);
        return;
    end

    buildable(i) = true;

    for j = 1 : numel(Tasks(i).parentNos)
        parentNo = Tasks(i).parentNos(j);
        if states(parentNo).stage ~= 5, buildable(i) = false; end
        if ~needed(parentNo)
            needed(parentNo) = true;
            check (parentNo) = true;
        end
    end

end

err = '';

end

%***********************************************************************************************************************

function PlaceHold(task, state)

filePath = HoldFilePath(task, state, false);

if ~isempty(filePath) && exist(filePath, 'file'), delete(filePath); end

filePath = HoldFilePath(task, state, true);

fid = fopen(filePath, 'w');
fclose(fid);

end

%***********************************************************************************************************************

function valid = ReleaseHold(task, state)

filePath = HoldFilePath(task, state, true);

valid = exist(filePath, 'file');

if valid, delete(filePath); end

end

%***********************************************************************************************************************

function filePath = HoldFilePath(task, state, me)

if me
    logFileName = LogFileName;
else
    logFileName = state.logFileName;
    if isempty(logFileName)
        filePath = '';
        return;
    end
end

switch state.stage
case {0, 3, 5}, rest = sprintf('_%s.hold', logFileName);
case 1        , rest = sprintf('_000000_%s.hold', logFileName);
case 2        , rest = sprintf('_%06u_%s.hold', state.batchNo, logFileName);
end

filePath = fullfile(WorkPath, [task.name rest]);

end

%***********************************************************************************************************************

function WriteResult(task, state, result)

save(MatFilePath(task,state), '-struct', 'result');

if state.stage == 3, delete(fullfile(WorkPath, [task.name '_*'])); end

end

%***********************************************************************************************************************

function DeleteResult(task)

delete(MatFilePath(task, NewState(5)));

end

%***********************************************************************************************************************
% Miscellaneous (serialized and unserialized).
%***********************************************************************************************************************

function filePath = MatFilePath(task, state)

switch state.stage
case {0, 3, 5}, final = true ; rest = '.mat';
case 1        , final = false; rest = sprintf('_000000_%06u.mat', state.numBatches);
case 2        , final = false; rest = sprintf('_%06u.mat', state.batchNo);
end

if final && task.perm
    filePath = fullfile(PermPath, [task.name rest]);
else
    filePath = fullfile(WorkPath, [task.name rest]);
end

end

%***********************************************************************************************************************

function state = NewState(varargin)

if nargin == 0
    state = struct;
elseif isnumeric(varargin{1})
    state.stage = varargin{1};
    varargin = varargin(2:end);
elseif isstruct(varargin{1})
    state = varargin{1};
    varargin = varargin(2:end);
else
    state = struct;
end

for i = 1 : 2 : numel(varargin)
    state.(varargin{i}) = varargin{i + 1};
end

if ~isfield(state, 'stage'      ), state.stage       = 0 ; end
if ~isfield(state, 'numBatches' ), state.numBatches  = 0 ; end
if ~isfield(state, 'batchNo'    ), state.batchNo     = 0 ; end
if ~isfield(state, 'logFileName'), state.logFileName = ''; end

end

%***********************************************************************************************************************

end
