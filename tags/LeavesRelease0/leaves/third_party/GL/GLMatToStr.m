function str = GLMatToStr(mat)

% GLMatToStr - 
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

if ndims(mat) > 2, error 'too many dimensions'; end

if islogical(mat)

    if isempty(mat)
        str = 'logical([])';
    else
        str = mat2str(mat);
    end

elseif isnumeric(mat)

    if strcmp(class(mat), 'double')
        str = mat2str(mat);
    else
        str = mat2str(mat, 'class');
    end

elseif ischar(mat)

    if size(mat,1) > 1, error 'only 1D strings are supported'; end

    str = ['''' strrep(mat, '''', '''''') ''''];

else

    error 'unsupported type';

end

return;
