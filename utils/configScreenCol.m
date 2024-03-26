function [white, gray, black] = configScreenCol(screen)
% CONFIGSCREENCOL Configures screen colors and text parameters for stimulus presentation.
%
%   CONFIGSCREENCOL(PARAMS, WIN, SCREEN) configures screen colors for 
%   stimulus presentation based on the SCREEN properties, and outputs
%   the corresponding white, gray, and black values.
%
%   Input Arguments:
%   - params: Structure containing experimental parameters.
%   - screen: PTB screen number.
%
%   Output Arguments:
%   - white: CLUT index for white color.
%   - gray: CLUT index for gray color.
%   - black: CLUT index for black color.


% Obtain the CLUT index for black.
black = BlackIndex(screen);

% Obtain the CLUT index for white.
white = WhiteIndex(screen);

% Calculate a gray value as the midpoint between black and white.
gray = round(white / 2);


end