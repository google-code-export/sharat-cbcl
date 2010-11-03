function DMDispJobs(pattern)

% DMDispJobs - List jobs.
%
% TODO

%***********************************************************************************************************************

if nargin < 1, pattern = '*'; end

[jobDirs, othDirs] = DMFindJobs(pattern);

if isempty(jobDirs) && isempty(othDirs), return; end

nameLen = 0;
dateLen = 0;

othNames = cell(1, numel(othDirs));
othDescs = cell(1, numel(othDirs));

for i = 1 : numel(othDirs)

    [dummy, name, ext, ver] = fileparts(othDirs{i});
    othNames{i} = [name ext ver];

    othDescs{i} = '** dir **';

    nameLen = max(nameLen, numel(othNames{i}));

end

jobNames = cell(1, numel(jobDirs));
jobDates = cell(1, numel(jobDirs));
jobDescs = cell(1, numel(jobDirs));

for i = 1 : numel(jobDirs)

    [dummy, name, ext, ver] = fileparts(jobDirs{i});
    jobNames{i} = [name ext ver];

    params = load(fullfile(resdir, jobDirs{i}, 'params.mat'), '-regexp', '(date|desc)');

    if isfield(params, 'date'), jobDates{i} = FormatDate(params.date); else jobDates{i} = ''; end
    if isfield(params, 'desc'), jobDescs{i} =            params.desc ; else jobDescs{i} = ''; end

    nameLen = max(nameLen, numel(jobNames{i}));
    dateLen = max(dateLen, numel(jobDates{i}));

end

if numel(othDirs) > 0, fprintf('\n'); end

for i = 1 : numel(othDirs)
    fprintf('%-*s  %-*s  %s\n', ...
        nameLen, othNames{i}, dateLen, '', othDescs{i});
end

if numel(jobDirs) > 0, fprintf('\n'); end

for i = 1 : numel(jobDirs)
    fprintf('%-*s  %-*s  %s\n', ...
        nameLen, jobNames{i}, dateLen, jobDates{i}, jobDescs{i});
end

fprintf('\n');

return;

%***********************************************************************************************************************

function date = FormatDate(str)

hour = str2double(str(10 : 11));
if hour == 0
    hour = sprintf('%02u', hour + 12);
    ampm = 'am';
elseif hour <= 11
    hour = sprintf('%02u', hour);
    ampm = 'am';
else
    hour = sprintf('%02u', hour - 12);
    ampm = 'pm';
end

date = [str(1 : 4) '-' str(5 : 6) '-' str(7 : 8) '  ' hour ':' str(12 : 13) ':' str(14 : 15) ampm];

return;
