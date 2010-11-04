function s = GLRemoveFields(s, names)

% GLRemoveFields - 
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

if ischar(names), names = {names}; end

for i = 1 : numel(names)
    if isfield(s, names{i})
        s = rmfield(s, names{i});
    end
end

return;
