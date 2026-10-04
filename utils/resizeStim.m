function resizedImage = resizeStim(image, params)
% RESIZESTIM Resizes an image based on input parameters.
% 
%   This function resizes the input image based on the specified mode and
%   width/height parameters. If mode is 'visualUnits', the width and height
%   parameters are treated as visual degrees of visual angle. If mode is
%   'pixelSize', the width and height parameters are treated as pixels.
%   The function uses the degToPix function to convert between
%   degrees of visual angle and pixels.
%
%   Parameters:
%   image: The input image to be resized.
%   params: A parameter structure containing the following elements:
%       resizeMode: The mode of resizing. Must be 'visualUnits' or 'pixelSize'.
%       outSize: The size of the image's longest side (visual degrees or
%           pixels). The other side follows from the image's aspect ratio in
%           pixels, so the image is never stretched. In 'visualUnits' mode
%           the longest side spans outSize degrees at the eye (see degToPix).
%       outWidth, outHeight: Older alternative to outSize: the width and/or
%           the height of the resized image. Giving only one derives the
%           other from the aspect ratio; giving both can stretch the image.
%
%   Returns:
%   resized_image: The resized image.
%
%   Example:
%   params.resizeMode = 'visualUnits';
%   params.outSize = 5;     % longest side spans 5 degrees
%   resized_image = resizeStim(input_image, params);
% 
%   Author
%   Tim Maniquet [28/2/24]

% If no dimension has been provided, raise an error
if ~isfield(params, 'outSize') && ~isfield(params, 'outWidth') && ~isfield(params, 'outHeight')
    error('None of ''outSize'', ''outWidth'' or ''outHeight'' is specified in params.');
end

% Check the resize mode: sizes in degrees go through degToPix (the stimulus
% is shown at the screen centre), sizes in pixels are used as they are. The
% side tells degToPix which side the angle is measured on.
if strcmpi(params.resizeMode, 'visualUnits')
    toPix = @(v, side) degToPix(v, params, 0, 0, side);
elseif strcmpi(params.resizeMode, 'pixelSize')
    toPix = @(v, side) v;
else
    error('Invalid resizing mode. Please use ''visualUnits'' or ''pixelSize''.');
end

% The image's own aspect ratio in pixels
imH = size(image, 1);
imW = size(image, 2);

% outSize: the longest side gets the size, the other side keeps the aspect
% ratio. Deriving the other side in degrees and converting both sides
% separately would stretch the image slightly, because degrees to pixels is
% not linear.
if isfield(params, 'outSize')
    if imW >= imH
        output_width_pixels = toPix(params.outSize, 'width');
        output_height_pixels = output_width_pixels * imH / imW;
    else
        output_height_pixels = toPix(params.outSize, 'height');
        output_width_pixels = output_height_pixels * imW / imH;
    end

% If both width and height are specified, use both as given
elseif isfield(params, 'outWidth') && isfield(params, 'outHeight')
    output_width_pixels = toPix(params.outWidth, 'width');
    output_height_pixels = toPix(params.outHeight, 'height');

% Otherwise convert the one given side and derive the other from the image's
% aspect ratio in pixels
elseif ~isfield(params, 'outWidth')
    output_height_pixels = toPix(params.outHeight, 'height');
    output_width_pixels = output_height_pixels * imW / imH;
else
    output_width_pixels = toPix(params.outWidth, 'width');
    output_height_pixels = output_width_pixels * imH / imW;
end

% Resize the image, rounding to the nearest pixel (imresize alone rounds up,
% which can add a pixel to each side)
resizedImage = imresize(image, max(round([output_height_pixels, output_width_pixels]), 1));

end
