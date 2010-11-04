function GLCompile(path, force)

% GLCompile - Run this after installation to compile all C/C++ components.
%
% Run GLCompile once, after installation, to compile all components of this
% toolbox that are written in C/C++.  (If you have machines running different
% combinations of architectures / operating systems, run it once per such
% combination.)
%
% Note that the GLSetPath command must have been run first, or MATLAB won't be
% able to find the GLCompile function.
%
% See also: GLSetPath.

%***********************************************************************************************************************

% Copyright (C) 2007  Jim Mutch  (www.jimmutch.com)
%
% This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public
% License as published by the Free Software Foundation; either version 3 of the License, or (at your option) any later
% version.
%
% This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied
% warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License along with this program.  If not, see
% <http://www.gnu.org/licenses/>.

%***********************************************************************************************************************

if nargin < 1, path  = fileparts(which('GLSetPath')); end
if nargin < 2, force = false; end

if ~force && exist(fullfile(path, 'Compile.m'), 'file')
    run(fullfile(path, 'Compile'));
    return;
end

includePath = fullfile(fileparts(mfilename('fullpath')), 'source');

[dummy, dirName] = fileparts(path);
source = strcmp(dirName, 'source');

prevPath = cd(path);

files = dir(path);

for i = 1 : numel(files)
    if files(i).isdir
        if ~ismember(files(i).name, {'.', '..', 'private'})
            GLCompile(fullfile(path, files(i).name), false);
        end
    else
        if ~isempty(regexp(files(i).name, '(\.c|\.cpp)$', 'once'))
            fprintf('compiling %s\n', files(i).name);
            flags{1} = ['-D' 'MEX_OS_' GLOSName  ];
            flags{2} = ['-D' 'MEX_COMP_' computer];
            flags{3} = ['-I' includePath         ];
            mex(flags{:}, files(i).name);
            if source, MoveExecutable(path, GLStrField(files(i).name, '.', 1, -2)); end
        end
    end
end

cd(prevPath);

return;

%***********************************************************************************************************************

function MoveExecutable(path, name)

sourcePath = fullfile(path, [name '.' mexext]);

targetPath = fileparts(path);

if ~isempty(regexp(name, '_private$', 'once'))
    targetPath = fullfile(targetPath, 'private');
    name = name(1 : end - 8);
    if ~exist(targetPath, 'dir'), mkdir(targetPath); end
end

targetPath = fullfile(targetPath, [name '.' mexext]);

if exist(targetPath, 'file'), delete(targetPath); end

movefile(sourcePath, targetPath);

return;
