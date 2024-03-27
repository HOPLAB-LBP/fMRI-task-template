function [fixSize, fixRect, fixCol] = setupFixation(params, winRect)
% SETUPFIXATION Sets up fixation parameters for drawing fixation point.
%
%   [fixSize, fixRect, fixCol] = SETUPFIXATION(params, winRect) sets up fixation parameters
%   based on input parameters and window dimensions.
%
%   Input Arguments:
%   - params:   Structure containing fixation parameters.
%   - winRect:  Rectangle defining the size of the window.
%
%   Output Arguments:
%   - fixSize:  Size of the fixation point in pixels.
%   - fixRect:  Rectangle coordinates for drawing the fixation point.
%   - fixCol:   Colors for the fixation point elements.
%
%   Example:
%   params.fixSize = [1, 2, 3]; % Fixation point sizes in degrees of visual angle
%   winRect = [0, 0, 800, 600]; % Example window size
%   [fixSize, fixRect, fixCol] = setupFixation(params, winRect);

% Check if the required fields are present in the params structure
requiredFields = {'fixSize', 'fixColMid', 'fixColIn', 'fixColOut'};
missingFields = setdiff(requiredFields, fieldnames(params));
if ~isempty(missingFields)
    error('setupFixation:paramsMissing', 'Required field(s) %s missing in the params structure.', strjoin(missingFields, ', '));
end

% Convert the fixation size from the parameters to pixels
fixSize = round(convertVisualUnits(params.fixSize, 'deg', 'px')); 

% Initialize an array to store rectangle coordinates for drawing the fixation point
fixRect = zeros(4, length(params.fixSize));

% For each dimension specified in params.fixSize, calculate the rectangle's coordinates.
% This loop allows for the creation of a composite fixation symbol, potentially consisting of multiple elements.
for i = 1:length(params.fixSize)
    % Calculate the rectangle for the fixation component.
    % The CenterRect function creates a rectangle of the specified size, centered within the window.
    % Dividing FixSize by 2 ensures the dimensions are correctly centered around the fixation point.
    fixRect(:,i) = CenterRect([0 0 fixSize(i)/2 fixSize(i)/2], winRect); 
end

% Define the colors for the fixation point. This matrix specifies colors for each element of the fixation.
% The sequence [0 0 0; 255 255 255; 0 0 0]' defines a black-white-black pattern when multiple elements are drawn.
% Use the parameters to define the colours
fixCol = [params.fixColIn;  params.fixColMid; params.fixColOut]';

end