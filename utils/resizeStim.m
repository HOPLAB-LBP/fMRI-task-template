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
%       outWidth: The width of the resized image (visual degrees or pixels).
%       outHeight: The height of the resized image (visual degrees or pixels).
%
%   Returns:
%   resized_image: The resized image.
%
%   Example:
%   resized_image = resizeStim(input_image, 'visualUnits', 'Height', 5);
% 
%   Author
%   Tim Maniquet [28/2/24]

% If no dimension has been provided, raise an error
if ~isfield(params, 'outWidth') && ~isfield(params, 'outHeight')
    error('Neither ''outWidth'' nor ''outHeight'' are specified in params.');
end

% Check the resize mode: sizes in degrees go through degToPix, sizes in
% pixels are used as they are
if strcmpi(params.resizeMode, 'visualUnits')
    toPix = @(v) degToPix(v, params);
elseif strcmpi(params.resizeMode, 'pixelSize')
    toPix = @(v) v;
else
    error('Invalid resizing mode. Please use ''visualUnits'' or ''pixelSize''.');
end

% If both width and height are specified, use both as given
if isfield(params, 'outWidth') && isfield(params, 'outHeight')
    output_width_pixels = toPix(params.outWidth);
    output_height_pixels = toPix(params.outHeight);

% Otherwise convert the one given side and derive the other from the image's
% aspect ratio in pixels. Deriving it in degrees and converting both sides
% separately would stretch the image slightly, because degrees to pixels is
% not linear.
elseif ~isfield(params, 'outWidth')
    output_height_pixels = toPix(params.outHeight);
    output_width_pixels = output_height_pixels * size(image, 2) / size(image, 1);
else
    output_width_pixels = toPix(params.outWidth);
    output_height_pixels = output_width_pixels * size(image, 1) / size(image, 2);
end

% Resize the image, rounding to the nearest pixel (imresize alone rounds up,
% which can add a pixel to each side)
resizedImage = imresize(image, max(round([output_height_pixels, output_width_pixels]), 1));

end
