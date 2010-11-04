function image = GLReadGray(input, window, flip)

% GLReadGray - Read a grayscale image and convert into standard format.
%
% IMAGE = GLReadGray(INPUT, WINDOW, FLIP) reads a grayscale image and returns it
% as a 2D matrix of doubles between 0.0 and 1.0.
%
%    INPUT - Either the path of an image file, or a matrix containing a
%    grayscale or color image.
%
%    WINDOW - Optional.  Can be used to read only a specified rectangle of the
%    image.  If given, must be a vector with elements [x1 y1 x2 y2].
%
%    FLIP - Optional.  If true, the image is returned right-left reflected.
%    Defaults to false.
%
% See also: GLResizeGray, GLMarkupGray, GLShowGray.

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

if nargin < 2, window = []   ; end
if nargin < 3, flip   = false; end

if strcmp(class(input),'double') && (ndims(input) == 2)

    image = input;

else

    if ischar(input)
        image = imread(abspath(input));
        if ~isinteger(image), error 'invalid image format'; end
    elseif isinteger(input)
        image = input;
    else
        error 'invalid input';
    end

    if (ndims(image) ~= 2) && (ndims(image) ~= 3)
        error 'invalid image dimensions';
    end

    if ndims(image) == 3
        if size(image,3) ~= 3, error 'size of color dimension must be 3'; end
        image = rgb2gray(image);
    end

    image = double(image) / double(intmax(class(image)));

end

if ~isempty(window)

    x1 = window(1);
    y1 = window(2);
    x2 = window(3);
    y2 = window(4);

    image = image(y1 : y2, x1 : x2);

end

if flip, image = image(:, end : -1 : 1); end

return;
