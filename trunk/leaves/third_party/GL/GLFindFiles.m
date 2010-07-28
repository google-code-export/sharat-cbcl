function names = GLFindFiles(basePath, format, range1, range2)

% GLFindFiles -
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

if nargin <= 2

    names = MatchFiles(basePath, format);

    [dummy, indexes] = sort(upper(names));
    names = names(indexes);

elseif nargin == 3

    all   = MatchFiles(basePath, '*');
    names = {};

    for i = 1 : numel(range1)
        name = sprintf(format, range1(i));
        if any(strcmp(name, all)), names{end + 1} = name; end
    end

else

    all   = MatchFiles(basePath, '*');
    names = {};

    for i = 1 : numel(range1)
        for j = 1 : numel(range2)
            name = sprintf(format, range1(i), range2(j));
            if any(strcmp(name, all)), names{end + 1} = name; end
        end
    end

end

if ~isempty(path)
    for i = 1 : numel(names)
        names{i} = fullfile(path, names{i});
    end
end

return;

%***********************************************************************************************************************

function names = MatchFiles(path, format)

list = dir(fullfile(abspath(path), format));

names = {list(~[list.isdir]).name};

return;
