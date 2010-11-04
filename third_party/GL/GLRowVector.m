function vector = GLRowVector(array, minCount, maxCount)

% GLRowVector - Convenience function for validating a row vector.
%
% VECTOR = GLRowVector(ARRAY, MINCOUNT, MAXCOUNT) reshapes a variable into row
% vector form and (optionally) ensures it has the desired number of elements.
%
%    ARRAY - The input variable.
%
%    MINCOUNT - Optional.  Minimum allowable number of elements.  Inputs with
%    fewer elements will cause an error.  Defaults to 0.
%
%    MAXCOUNT - Optional.  Maximum allowable number of elements.  Inputs with
%    more elements will be truncated.  Defaults to Inf.
%
% See also: GLDfltValue.

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

if nargin < 2, minCount = 0  ; end
if nargin < 3, maxCount = Inf; end

if ischar(array) && ~isempty(array), array = array(1, :); end

if numel(array) < minCount, error('at least %u element(s) required', minCount); end

if numel(array) > maxCount, array = array(1 : maxCount); end

if isempty(array)
    vector = reshape(array, 0, 0);
else
    vector = array(:)';
end

return;
