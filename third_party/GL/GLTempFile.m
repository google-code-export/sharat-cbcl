function filePath = GLTempFile(create);

% GLTempFile -
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

if nargin < 1, create = false; end

tempPath = tempdir;
hostName = GLHostName;

while true

    time   = datestr(now, 30);
    random = sprintf('%06u', floor(rand * 1000000));

    filePath = fullfile(tempPath, [hostName '_' time '_' random]);

    if ~exist(filePath, 'file'), break; end

end

if create
    fid = fopen(filePath, 'w');
    fclose(fid);
end

return;
