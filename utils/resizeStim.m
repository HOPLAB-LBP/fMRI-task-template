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

% Check which dimensions have been specified and calculate AR accordingly
% If no dimension has been provided, raise an error
if ~isfield(params, 'outWidth') && ~isfield(params, 'outHeight')
    error('Neither ''outWidth'' nor ''outHeight'' are specified in params.');

% If both width and height are specified, go ahead
elseif isfield(params, 'outWidth') && isfield(params, 'outHeight')
    % Report the values accordingly
    width = params.outWidth;
    height = params.outHeight;

% If no width has been provided
elseif ~isfield(params, 'outWidth')
    % Calculate width proportionally
    aspect_ratio = size(image, 2) / size(image, 1);
    height = params.outHeight;
    width = height * aspect_ratio;

% Otherwise no height has been provided
else
    % Calculate height proportionally
    aspect_ratio = size(image, 1) / size(image, 2);
    width = params.outWidth;
    height = width * aspect_ratio;

end

% Check the resize mode
if strcmpi(params.resizeMode, 'visualUnits')
    % Convert visual degrees to pixels
    output_width_pixels = degToPix(width, params);
    output_height_pixels = degToPix(height, params);
elseif strcmpi(params.resizeMode, 'pixelSize')
    output_width_pixels = width;
    output_height_pixels = height;
else
    error('Invalid resizing mode. Please use ''visualUnits'' or ''pixelSize''.');
end

% Resize the image
resizedImage = imresize(image, [output_height_pixels , output_width_pixels]);

end
