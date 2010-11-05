function field = GLStrField(string, delim, num1, num2)

% GLStrField - Extract field(s) from a string based on a delimiter.
%
% GLStrField(STRING, DELIM, STARTPOS, ENDPOS) extracts zero or more fields from
% a string, assuming the fields are separated by a specific delimiter character.
% STARTPOS and ENDPOS are the ordinal field numbers (not character positions) of
% the first and last fields to extract.  If ENDPOS is omitted, only a single
% field is extracted.
%
% Examples:
%
%    GLStrField('one-of-a-kind', '-', 2)     -->  'of'
%    GLStrField('one-of-a-kind', '-', 2, 3)  -->  'of-a'
%
% Negative field numbers count backwards from the end of the string, with the
% last field being -1, second-to-last being -2, etc.
%
% Examples:
%
%    GLStrField('one-of-a-kind', '-', -4)      -->  'one'
%    GLStrField('one-of-a-kind', '-', -4, -3)  -->  'one-of'

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

if nargin < 4, num2 = num1; end

indexes   = strfind(string,delim);
numFields = numel(indexes) + 1;

if num1 < 0, num1 = num1 + numFields + 1; end
if num2 < 0, num2 = num2 + numFields + 1; end

if num1 <= 1
    first = 1;
elseif num1 <= numFields
    first = indexes(num1 - 1) + 1;
else
    first = numel(string) + 1;
end

if num2 < 1
    last = 0;
elseif num2 < numFields
    last = indexes(num2) - 1;
else
    last = numel(string);
end

field = string(first : last);

return;
