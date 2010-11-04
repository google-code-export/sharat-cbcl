function GLSetPath(path)

% GLSetPath - Run this on MATLAB startup to add the toolbox to the MATLAB path.
%
% To use this toolbox, its directories need to be added to the MATLAB path.
% This has to happen every time you start MATLAB, so it's best to do it
% automatically from your startup.m file.  This can be accomplished by adding
% the following line to startup.m.
%
%    run ???/GLSetPath
%
% where "???" is replaced by the main toolbox directory, which contains the
% GLSetPath function.
%
% See also: GLEnvVar, GLCompile.

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

if nargin < 1

    path = fileparts(mfilename('fullpath'));

    [dummy, mainDir] = fileparts(path);
    fprintf('Adding %s to the MATLAB path.  Type ''help %s'' for help.\n', mainDir, mainDir);

end

files = dir(path);

for i = numel(files) : -1 : 1
    if files(i).isdir && (files(i).name(1) ~= '.')
        if ~ismember(files(i).name, {'data', 'private', 'scripts', 'source', 'tests'})
            GLSetPath(fullfile(path, files(i).name));
        end
    end
end

addpath(path);

return;
