function GLShowGray(im)

% GLShowGray - Show a grayscale image on the screen.
%
% GLShowGray(IMAGE) shows a grayscale image on the screen using the current
% axes.
%
%    IMAGE - A grayscale image, represented as a 2D matrix of doubles between
%    0.0 and 1.0.
%
% See also: GLReadGray, GLResizeGray, GLMarkupGray.

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

colormap gray;

image(uint8(floor(im * 63)));

axis image off;

return;
