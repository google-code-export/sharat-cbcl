function r = GLResizeGray(image, sizeMode, sizeNum, scaleFactor)

% GLResizeGray - Resize a grayscale image.
%
% IMAGE = GLResizeGray(IMAGE, SIZEMODE, SIZE, SCALEFACTOR) resizes a grayscale
% image to a desired size, which can be specified in a number of ways.
%
%    IMAGE - A grayscale image, represented as a 2D matrix of doubles between
%    0.0 and 1.0.
%
%    SIZEMODE, SIZE - Together these determine how the image will be resized.
%    The possible values of SIZEMODE, and the corresponding meaning of SIZE for
%    each, are as follows.
%
%       ***  Note that the aspect ratio is always preserved.
%
%       'x'      - Make the image be SIZE pixels wide.
%       'y'      - Make the image be SIZE pixels high.
%       'short'  - Make the image's shorter edge be SIZE pixels.
%       'long'   - Make the image's longer edge be SIZE pixels.
%       'factor' - Multiply both width and height by a factor of SIZE.
%       'fit'    - TODO
%       'crop'   - TODO
%
%       ***  The following options do not actually resize the image, but simply
%            verify that a certain condition is met.
%
%       'min'   - Ensure shorter edge is at least SIZE pixels.
%       'exact' - Ensure image is exactly this size.  Here SIZE = (y, x).
%
%    SCALEFACTOR - Optional.  Can be used to apply a further multiplicative
%    scaling factor.  Defaults to 1.
%
% IMAGESIZE = GLResizeGray(IMAGESIZE, ...) is similar except that it takes only
% the size of an input image (y, x) and returns the size that would result,
% given the other arguments.
%
% IMAGESIZE = GLResizeGray('min', ...) returns the minimum possible image size
% given the arguments.  Note that this is only possible for certain values of
% SIZEMODE.
%
% IMAGESIZE = GLResizeGray('exact', ...) returns the exact image size that will
% result, given the arguments.  Note that this is only possible for certain
% values of SIZEMODE.
%
% See also: GLReadGray, GLMarkupGray, GLShowGray.

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

if nargin < 4, scaleFactor = 1; end

if isnumeric(image)

    r = Resize(image, sizeMode, sizeNum, scaleFactor);

elseif ischar(image) && strcmp(image, 'validate')

    r = Validate(sizeMode, sizeNum);

elseif ischar(image) && strcmp(image, 'min')

    r = MinSize(sizeMode, sizeNum, scaleFactor);

elseif ischar(image) && strcmp(image, 'exact')

    r = ExactSize(sizeMode, sizeNum, scaleFactor);

else

    error 'argument 1 invalid';

end

return;

%***********************************************************************************************************************

function r = Validate(sizeMode, sizeNum)

if (numel(sizeMode) > 1) && (sizeMode(1) == '@')
    % TODO: document this option
    r = GLRowVector(sizeNum, 0);
    return;
end

switch sizeMode
case {'x', 'y', 'short', 'long', 'factor', 'min'}

    r = sizeNum(1);

case {'fit', 'crop', 'exact'}

    r = GLRowVector(sizeNum, 2, 2);

otherwise

    error('invalid sizeMode: "%s"', sizeMode);

end

return;

%***********************************************************************************************************************

function r = MinSize(sizeMode, sizeNum, scaleFactor)

switch sizeMode
case {'short', 'min'}

    crop = repmat(sizeNum, 1, 2);

case {'fit', 'crop', 'exact'}

    crop = sizeNum;

otherwise

    crop = [];

end

r = round(crop * scaleFactor);

return;

%***********************************************************************************************************************

function r = ExactSize(sizeMode, sizeNum, scaleFactor)

switch sizeMode
case {'fit', 'crop', 'exact'}

    crop = sizeNum;

otherwise

    crop = [];

end

r = round(crop * scaleFactor);

return;

%***********************************************************************************************************************

function r = Resize(image, sizeMode, sizeNum, scaleFactor)

if sizeMode(1) == '@'
    r = feval(sizeMode(2:end), image, sizeNum, scaleFactor);
    return;
end

if numel(image) == 2
    imageSize = image;
else
    imageSize = size(image);
end

switch sizeMode
case 'x'

    factor = sizeNum / imageSize(2);
    crop   = [];

case 'y'

    factor = sizeNum / imageSize(1);
    crop   = [];

case 'short'

    factor = sizeNum / min(imageSize);
    crop   = [];

case 'long'

    factor = sizeNum / max(imageSize);
    crop   = [];

case 'factor'

    factor = sizeNum;
    crop   = [];

case 'fit'

    if imageSize(2) / imageSize(1) <= sizeNum(2) / sizeNum(1)
        factor = sizeNum(2) / imageSize(2);
    else
        factor = sizeNum(1) / imageSize(1);
    end

    crop = sizeNum;

case 'crop'

    if any(imageSize < sizeNum)
        error('image must be at least %u pixels wide by %u high', sizeNum(2), sizeNum(1));
    end

    factor = 1;
    crop   = sizeNum;

case 'min'

    if min(imageSize) < sizeNum
        error('shorter edge of image must be at least %u pixels', sizeNum);
    end

    factor = 1;
    crop   = [];

case 'exact'

    if any(imageSize ~= sizeNum)
        error('image must be %u pixels wide by %u high', sizeNum(2), sizeNum(1));
    end

    factor = 1;
    crop   = [];

otherwise

    error('invalid sizeMode: "%s"', sizeMode);

end

factorSize = round(imageSize * factor * scaleFactor);

if isempty(crop)
    cropSize = factorSize;
else
    cropSize = round(crop * scaleFactor);
end

if numel(image) == 2
    r = cropSize;
    return;
end

if any(factorSize ~= size(image))

    newImage = imresize(image, factorSize, 'bicubic');

    oldMin   = min(image   (:));
    oldRange = max(image   (:)) - oldMin;
    newMin   = min(newImage(:));
    newRange = max(newImage(:)) - newMin;

    if newRange == 0
        image = repmat(oldMin, factorSize);
    else
        image = (newImage - newMin) / newRange * oldRange + oldMin;
    end

end

if any(cropSize ~= size(image))

    x1 = 1 + floor((size(image,2) - cropSize(2)) / 2);
    y1 = 1 + floor((size(image,1) - cropSize(1)) / 2);
    x2 = x1 + cropSize(2) - 1;
    y2 = y1 + cropSize(1) - 1;

    image = image(y1:y2, x1:x2);

end

r = image;

return;
