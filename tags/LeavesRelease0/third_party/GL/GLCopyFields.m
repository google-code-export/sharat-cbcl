function target = GLCopyFields(target, source, names)

% GLCopyFields - 
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

if (numel(target) ~= 1) || (numel(source) ~= 1)
    error 'only single structures allowed';
end

if nargin < 3, names = fieldnames(source); end

if ischar(names), names = {names}; end

for i = 1 : numel(names)
    if isfield(source, names{i})
        target.(names{i}) = source.(names{i});
    end
end

return;
