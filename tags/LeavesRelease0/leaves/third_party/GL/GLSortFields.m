function s = GLSortFields(s, sortedNames)

% GLSortFields -
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

if numel(s) ~= 1, error 'only single structures allowed'; end

if ischar(sortedNames), sortedNames = {sortedNames}; end

names = fieldnames(s);

sortedNames = [sortedNames(:) ; sort(names)];

sortArray = zeros(numel(names), 2);

for i = 1 : numel(names)
    j = find(strcmp(names{i}, sortedNames), 1);
    sortArray(i, 1) = j;
    sortArray(i, 2) = i;
end

sortArray = sortrows(sortArray, 1);

s = orderfields(s, sortArray(:, 2));

return;
