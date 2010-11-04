function names = GLFindDirs(basePath, format)

% GLFindDirs -
%
% TODO

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

if nargin < 2, format = '*'; end

[path, name, ext, ver] = fileparts(format);
if ~isempty(path)
    basePath = fullfile(basePath, path);
    format   = [name ext ver];
end

list = dir(fullfile(abspath(basePath), format));

names = {list.name};
names = names([list.isdir] & ~strcmp(names, '.') & ~strcmp(names, '..'));

[dummy, indexes] = sort(upper(names));
names = names(indexes);

if ~isempty(path)
    for i = 1 : numel(names)
        names{i} = fullfile(path, names{i});
    end
end

return;
