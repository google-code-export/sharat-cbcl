function DMRenameJob(oldJobDir, newJobDir)

% DMRenameJob - 
%
% TODO

%***********************************************************************************************************************

if strcmp(oldJobDir, newJobDir), return; end

oldPermPath = fullfile(resdir , oldJobDir);
newPermPath = fullfile(resdir , newJobDir);
oldWorkPath = fullfile(workdir, oldJobDir);
newWorkPath = fullfile(workdir, newJobDir);
separate = ~strcmp(resdir, workdir);

if ~exist(oldPermPath, 'dir') || (separate && (exist(oldWorkPath, 'file') == 2))
    error('"%s" is not a directory', oldJobDir);
end
if exist(newPermPath, 'file') || (separate && exist(newWorkPath, 'file'))
    error('"%s" already exists', newJobDir);
end

parent = fileparts(newJobDir);
if ~isempty(parent)
    pp = fullfile(resdir , parent);
    wp = fullfile(workdir, parent);
    if (exist(pp, 'file') == 2) || (separate && (exist(wp, 'file') == 2))
        error('"%s" is not a directory', parent);
    end
    if ~exist(pp, 'dir'), mkdir(pp); end
    if separate && exist(oldWorkPath, 'dir') && ~exist(wp, 'dir'), mkdir(wp); end
end

movefile(oldPermPath, newPermPath);
if separate && exist(oldWorkPath, 'dir'), movefile(oldWorkPath, newWorkPath); end

return;
