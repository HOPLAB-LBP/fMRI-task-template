function size = convertVisualUnits(size, varargin)
% Convert the size of a stimulus from one unit to another. The function 
% assumes square pixels. The function is inspired by 
% https://www.sr-research.com/visual-angle-calculator/, and therefore 
% follows the same calculations. The default parameters are set to match
% the KU Leuven fMRI scanner facilities:
%
% from_unit = 'deg'
% to_unit = 'px'
% distance_mm = 630 
% display_resolution_x = 1920  
% display_resolution_y = 1080  
% display_size_x_mm = 340  
% display_size_y_mm = 190  
%
% Parameters:
% size (int or float): The size of the stimulus to be converted.
% from_unit (str): The unit of 'size'. Must be 'mm', 'deg', or 'px'.
% to_unit (str): The unit to which 'size' should be converted. Must be 'mm', 'deg', or 'px'.
% distance_mm (int, optional): The distance from the viewer to the display, in millimeters. This argument is only needed if converting between visual angle and millimeters.
% display_resolution_x (int, optional): The horizontal resolution of the display, in pixels. This argument is only needed if converting between pixels and millimeters.
% display_resolution_y (int, optional): The vertical resolution of the display, in pixels. This argument is only needed if converting between pixels and millimeters.
% display_size_x_mm (int, optional): The width of the display, in millimeters. This argument is only needed if converting between pixels and millimeters.
% display_size_y_mm (int, optional): The height of the display, in millimeters. This argument is only needed if converting between pixels and millimeters.
%
% Returns:
% float: The size of the stimulus in the desired unit.
%
% Example:
% convert_units(10, 'deg', 'mm', 100) -> 17.4977
%
% Andrea Costantino [28/12/2022]

% Set default values for optional arguments
default_values = {'deg','px',630, 1920, 1080, 340, 190};
% Check number of input arguments
num_inputs = length(varargin);
% Overwrite default values with user-provided values
default_values(1:num_inputs) = varargin;
% Assign default values to variables
[from_unit, to_unit, distance_mm, display_resolution_x, display_resolution_y, display_size_x_mm, display_size_y_mm] = default_values{:};
% Check that the specified units are valid
%     assert (any(strcmpi(from_unit, ['mm', 'deg', 'px']&& any(strcmpi(to_unit, ['mm', 'deg', 'px']))))); 'from_unit and to_unit must be mm, deg, or px';
% Convert size to millimeters
if strcmpi(from_unit, 'deg')
    % Convert visual angle to radians
    size = deg2rad(size);
    % Calculate the size of the stimulus in millimeters
    size = 2 * distance_mm * tan(size / 2);
elseif strcmpi(from_unit, 'px')
    % Calculate the size of one pixel in millimeters
    pixel_size_x_mm = display_size_x_mm / display_resolution_x;
    pixel_size_y_mm = display_size_y_mm / display_resolution_y;
    % Calculate the size of the stimulus in millimeters
    size = size * max(pixel_size_x_mm, pixel_size_y_mm);
end

% Convert millimeters to the desired unit
if strcmpi(to_unit, 'deg')
    % Calculate the visual angle in radians
    visual_angle = 2 * atan(size / (2 * distance_mm));
    % Convert visual angle to degrees
    size = rad2deg(visual_angle);
elseif strcmpi(to_unit, 'px')
    % Calculate the size of one pixel in millimeters
    pixel_size_x_mm = display_size_x_mm / display_resolution_x;
    pixel_size_y_mm = display_size_y_mm / display_resolution_y;
    % Calculate the size of the stimulus in pixels
    size = size / max(pixel_size_x_mm, pixel_size_y_mm);
end

end


