function DMPrintf(format, varargin)

% DMPrintf - Output a message, forcing immediate update of any diary file.
%
% DMPrintf(FORMAT, ...) is the same as FPRINTF with no destination file.  It
% passes its arguments directly to FPRINTF to output a message to the console.
% The only difference is that if the MATLAB DIARY feature is currently on,
% DMPrintf forces the diary file to be updated immediately -- buffering is
% disabled.
%
% This is useful in a multiprocessing environment when you want someone on
% another computer to be able to check the status of your process by looking at
% your diary file.
%
% See also: FPRINTF, DIARY.

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

fprintf(format, varargin{:});

if strcmp(get(0,'Diary'), 'on')
    diary off;
    diary on;
end

return;
