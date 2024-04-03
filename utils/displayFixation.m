function displayFixation(win, winRect, params, in)
% DISPLAYFIXATION - Draw a fixation cross on the screen.
%
%   DISPLAYFIXATION(win, winRect, params, in) draws a fixation cross on the
%   specified Psychtoolbox window 'win' within the given window rectangle
%   'winRect'. Use this function to write your fixation cross element. 
%   Two default choices are present: 'round', which draws a circular
%   fixation target, and 'cross', which draws a black '+' cross.
%
%   Hint: when writing your own fixation element: use the black, white, and 
%   gray values from the input parameter.
%
%   Input:
%       - win: Psychtoolbox window pointer.
%       - winRect: Window rectangle defining the coordinates of the window.
%       - params: Structure containing parameters for fixation cross
%                 customization.
%       - in: Structure containing input data, including color values.
%
%   Usage:
%       displayFixation(win, winRect, params, in) draws the fixation cross
%       on the screen using the specified parameters and colors.

% Check if the required fields are present in the params structure
requiredFields = {'fixSize', 'fixType'};
missingFields = setdiff(requiredFields, fieldnames(params));
if ~isempty(missingFields)
    error('createLogFile:paramsMissing', 'Required field(s) %s missing in the params structure.', strjoin(missingFields, ', '));
end

% If the user asked for a 'round' type of fixation
if strcmp(params.fixType, 'round')
    % Make a black-white-black circular target fixation
    
    % Calculate the size of each individual element
    outElement = params.fixSize;
    midElement = outElement / 1.2;
    centerElement = outElement / 6;
    
    % Join the three element sizes in an array
    rectSize = [outElement midElement centerElement];
    
    % Convert the element sizes from to pixels
    fixSize = round(convertVisualUnits(rectSize, 'deg', 'px')); 
    
    % Initialize an array to store rectangle coordinates for drawing the fixation point
    fixRect = zeros(4, length(fixSize));
    
    % For each dimension specified in fixSize, calculate the rectangle's coordinates.
    % This loop allows for the creation of a composite fixation symbol, potentially consisting of multiple elements.
    for i = 1:length(fixSize)
        % Calculate the rectangle for the fixation component.
        % The CenterRect function creates a rectangle of the specified size, centered within the window.
        % Dividing FixSize by 2 ensures the dimensions are correctly centered around the fixation point.
        fixRect(:,i) = CenterRect([0 0 fixSize(i)/2 fixSize(i)/2], winRect); 
    end
    
    % Define the colors for the fixation point. This matrix specifies colors 
    % for each element of the fixation.
    fixCol = [in.black in.black in.black
              in.white in.white in.white 
              in.black in.black in.black]';
    
    % Draw the actual fixation cross
    Screen('FillOval', win, fixCol, fixRect); % Draw the fixation cross

elseif strcmp(params.fixType, 'cross')

    % Make a fixation cross with two intersected rectangles
    
    % Decide on the colour of the fixation cross
    fixCol = in.black;
    
    % Define the size and position of the fixation cross (in pixels)
    crossLength = round(convertVisualUnits(params.fixSize, 'deg', 'px')); % Length of each arm of the cross
    crossWidth = round(crossLength/10); % Width of the cross lines
    centerX = winRect(3) / 2;
    centerY = winRect(4) / 2;
    
    % Define the coordinates of the fixation cross
    crossCoords = [centerX - crossLength, centerY - crossWidth / 2, centerX + crossLength, centerY + crossWidth / 2;...  % Horizontal line
                   centerX - crossWidth / 2, centerY - crossLength, centerX + crossWidth / 2, centerY + crossLength]'; % Vertical line
    
    % Draw the actual fixation cross
    Screen('FillRect', win, fixCol, crossCoords); % Draw the fixation cross

end

end