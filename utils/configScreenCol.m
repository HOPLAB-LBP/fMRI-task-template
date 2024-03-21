function [white, gray, black] = configScreenCol(params)
% CONFIGSCREENCOL Configures screen colors and text parameters for stimulus presentation.
%
%   [white, gray, black] = CONFIGSCREENCOL(params) configures screen colors
%   and text parameters for stimulus presentation based on the input parameters
%   in the structure 'params'.
%
%   Input Arguments:
%   - params: Structure containing parameters for screen configuration.
%             It must contain the following fields:
%             - textSize: Font size for text displayed on screen.
%             - textFont: Font type for text displayed on screen.
%
%   Output Arguments:
%   - white: CLUT index for white color.
%   - gray: CLUT index for gray color.
%   - black: CLUT index for black color.
%
%   Example:
%   params.textSize = 24;
%   params.textFont = 'Helvetica';
%   [white, gray, black] = configScreenCol(params);


% Configure the text and color parameters for stimulus presentation.

% Set the font size for text displayed onscreen.
Screen('TextSize', win, params.textSize);

% Set the font type to Helvetica for readability.
Screen('TextFont', win, params.textFont);

% Obtain the CLUT index for black.
black = BlackIndex(screen);

% Obtain the CLUT index for white.
white = WhiteIndex(screen);

% Calculate a gray value as the midpoint between black and white.
gray = round(white / 2); 

end