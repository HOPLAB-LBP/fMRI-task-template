function resized_image = resizeStim(image, mode, varargin)
% RESIZESTIM Resizes an image based on input parameters.
%   This function resizes the input image based on the specified mode and
%   width/height parameters. If mode is 'visualUnits', the width and height
%   parameters are treated as visual degrees of visual angle. If mode is
%   'pixelSize', the width and height parameters are treated as pixels.
%   The function uses the convertVisualUnits function to convert between
%   degrees of visual angle and pixels.
%
%   Parameters:
%   image: The input image to be resized.
%   mode: The mode of resizing. Must be 'visualUnits' or 'pixelSize'.
%   Name-Value Pair Arguments:
%   'width': The width of the resized image (visual degrees or pixels).
%   'height': The height of the resized image (visual degrees or pixels).
%
%   Returns:
%   resized_image: The resized image.
%
%   Example:
%   resized_image = resizeStim(input_image, 'visualUnits', 'Height', 5);


% Parse name-value pair arguments
p = inputParser;
addParameter(p, 'width', []);
addParameter(p, 'height', []);
parse(p, varargin{:});

% Retrieve width and height values
width = p.Results.width;
height = p.Results.height;


% If only one dimension is specified, calculate the other dimension proportionally
if isempty(width)
    % Calculate width proportionally
    aspect_ratio = size(image, 2) / size(image, 1);
    width = height * aspect_ratio;
elseif isempty(height)
    % Calculate height proportionally
    aspect_ratio = size(image, 1) / size(image, 2);
    height = width * aspect_ratio;
end

% Check mode
if strcmpi(mode, 'visualUnits')
    % Convert visual degrees to pixels
    output_width_pixels = convertVisualUnits(width, 'deg', 'px');
    output_height_pixels = convertVisualUnits(height, 'deg', 'px');
elseif strcmpi(mode, 'pixelSize')
    output_width_pixels = width;
    output_height_pixels = height;
else
    error('Invalid resizing mode. Please use ''visualUnits'' or ''pixelSize''.');
end

% Resize the image
resized_image = imresize(image, [output_height_pixels , output_width_pixels]);

end
