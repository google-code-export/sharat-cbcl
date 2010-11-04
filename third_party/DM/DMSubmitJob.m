function DMSubmitJob(path, jobDir, buildNames, varargin)

% DMSubmitJob -
%
% TODO

%***********************************************************************************************************************

current = cd(path);
path = cd;
cd(current);

if ~DMReadTask(jobDir, 'params', 'exist')
    error('job "%s" does not exist', jobDir);
end

if ischar(buildNames)
    if strcmp(buildNames, '') || strcmp(buildNames, 'all')
        buildNames = {};
    elseif ~isletter(buildNames(1))
        error('task name "%s" is invalid', buildNames);
    else
        buildNames = {buildNames};
    end
end

if (numel(varargin) >= 1) && isstruct(varargin{1})
    options = varargin{1};
    varargin = varargin(2 : end);
elseif (numel(varargin) >= 1) && iscell(varargin{1})
    options = struct(varargin{1}{:});
    varargin = varargin(2 : end);
else
    options = struct;
end

desc    = [jobDir sprintf(' %s', buildNames{:})];
command = ['mlrun ' startdir ' %inpFilePath% %outFilePath%'];

contents = {};

contents{end+1} = sprintf('ap(''%s'');', path);

contents{end+1} = sprintf('jobDir=''%s'';', jobDir);

if isempty(buildNames)
    contents{end+1} = 'buildNames = {};';
else
    for i = 1 : numel(buildNames)
        contents{end+1} = sprintf('buildNames{%u}=''%s'';', i, buildNames{i});
    end
end

names = fieldnames(options);
for i = 1 : numel(names)
    contents{end+1} = sprintf('options.%s=%s;', names{i}, GLMatToStr(options.(names{i})));
end

contents{end+1} = 'options.logFileName=''%baseFileName%'';';
contents{end+1} = 'options.runFilePath=''%runFilePath%'';';
contents{end+1} = 'options.stepFilePath=''%stepFilePath%'';';

contents{end+1} = 'DMRunJob(jobDir, buildNames, options);';

CMSubmit(desc, command, contents, varargin{:});

return;
