function newImage = GLMarkupGray(image, windows, thickness, pad)

% GLMarkupGray - Draw rectangular windows on a grayscale image.
%
% IMAGE = GLMarkupGray(IMAGE, WINDOWS, THICKNESS, PAD) draws any number of
% rectangular windows on a grayscale image.
%
%    IMAGE - A grayscale image, represented as a 2D matrix of doubles between
%    0.0 and 1.0.
%
%    WINDOWS - Zero or more columns of the form [x1 y1 x2 y2]'.  Optionally,
%    columns may contain a fifth element which specifies the pixel value to use
%    when drawing that particular window's border; the default color is 1.0
%    (white).
%
%    THICKNESS - Optional.  Thickness of window borders, in pixels.  The default
%    thickness is 1 pixel.
%
%    PAD - Optional.  If true, the image will be padded (if necessary) so that
%    any windows extending outside the image boundaries may be fully drawn.
%    Defaults to false.
%
% See also: GLReadGray, GLResizeGray, GLShowGray.

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

if nargin < 3, thickness = 1    ; end
if nargin < 4, pad       = false; end

if pad

    xmin = min(windows(1,:));
    ymin = min(windows(2,:));
    xmax = max(windows(3,:));
    ymax = max(windows(4,:));

    if xmin < 1            , lpad = 1 - xmin            ; else lpad = 0; end
    if ymin < 1            , tpad = 1 - ymin            ; else tpad = 0; end
    if xmax > size(image,2), rpad = xmax - size(image,2); else rpad = 0; end
    if ymax > size(image,1), bpad = ymax - size(image,1); else bpad = 0; end

    newImage = repmat(0.5, tpad + size(image,1) + bpad, lpad + size(image,2) + rpad);

    newImage(tpad + 1 : tpad + size(image,1), lpad + 1 : lpad + size(image,2)) = image;

    windows([1 3],:) = windows([1 3],:) + lpad;
    windows([2 4],:) = windows([2 4],:) + tpad;

else

    newImage = image;

end

for i = 1 : size(windows,2)

    if size(windows,1) < 5
        color = 1;
    else
        color = windows(5,i);
    end

    for t = 0 : thickness - 1;

        x1 = max(1               , windows(1,i) - t);
        y1 = max(1               , windows(2,i) - t);
        x2 = min(size(newImage,2), windows(3,i) + t);
        y2 = min(size(newImage,1), windows(4,i) + t);

        for y = y1 : y2
            newImage(y,x1) = color;
            newImage(y,x2) = color;
        end

        for x = x1 : x2
            newImage(y1,x) = color;
            newImage(y2,x) = color;
        end

    end

end

return;
