function DMDeleteJob(jobDir)

% DMDeleteJob - 
%
% TODO

%***********************************************************************************************************************

permPath = fullfile(resdir , jobDir);
workPath = fullfile(workdir, jobDir);
separate = ~strcmp(permPath, workPath);

if exist(fullfile(permPath, 'params.mat'), 'file')
    ans = rmdir(permPath, 's');
    if separate, ans = rmdir(workPath, 's'); end
end

return;
