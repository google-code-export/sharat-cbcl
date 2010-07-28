function [jobDirs, othDirs, multi] = DMFindJobs(pattern)

% DMFindJobs - Find jobs.
%
% TODO

%***********************************************************************************************************************

if nargin < 1, pattern = '*'; end

permPath = resdir;

if exist(fullfile(permPath, pattern, 'params.mat'), 'file')
    jobDirs = {pattern};
    othDirs = {};
    multi   = false;
    return;
end

if exist(fullfile(permPath, pattern), 'dir')
    basePath = pattern;
    pattern  = '*';
else
    [basePath, name, ext, ver] = fileparts(pattern);
    pattern = [name ext ver];
end

list = dir(fullfile(permPath, basePath, pattern));

jobDirs = {};
jobKeys = {};
othDirs = {};
othKeys = {};

for i = 1 : numel(list)
    if list(i).isdir && ~ismember(list(i).name, {'.', '..'})
        if exist(fullfile(permPath, basePath, list(i).name, 'params.mat'), 'file')
            jobDirs{end+1} = fullfile(basePath, list(i).name);
            jobKeys{end+1} = upper(list(i).name);
        else
            othDirs{end+1} = fullfile(basePath, list(i).name);
            othKeys{end+1} = upper(list(i).name);
        end
    end
end

[dummy, indexes] = sort(jobKeys);
jobDirs = jobDirs(indexes);

[dummy, indexes] = sort(othKeys);
othDirs = othDirs(indexes);

multi = true;

return;
