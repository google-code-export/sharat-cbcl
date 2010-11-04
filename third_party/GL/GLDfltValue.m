function val = GLDfltValue(structure, fieldName, dflt, varargin)

% GLDfltValue - Convenience function for extracting a parameter from a struct.
%
% GLDfltValue(STRUCT, FIELD, DFLT) tries to extract a named field from a
% structure.  If the field exists, its first element is returned.  Otherwise,
% the specified default value is returned.
%
% GLDfltValue(STRUCT, FIELD, DFLT, MINCOUNT, MAXCOUNT) is similar except that it
% allows the extracted field to be a row vector.
%
%    MINCOUNT - Minimum allowable number of elements.  Fields with fewer
%    elements will cause an error.
%
%    MAXCOUNT - Optional.  Maximum allowable number of elements.  Fields with
%    more elements will be truncated.  Defaults to Inf.
%
% See also: GLRowVector.

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

if ~isfield(structure, fieldName)
    val = dflt;
    return;
end

val = structure.(fieldName);

if nargin < 4
    val = val(1);
else
    val = GLRowVector(val, varargin{:});
end

return;
