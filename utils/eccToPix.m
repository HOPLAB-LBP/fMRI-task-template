function px = eccToPix(ecc, params)
% ECCTOPIX Distance in pixels from the screen centre to a point ecc degrees of
% visual angle away from it, using the screen geometry in params (selected for
% the current mode, MRI or PC, by parseParameterFile).
%
%   px = eccToPix(ecc, params)
%
%   This is the single place that holds the screen geometry: degToPix (sizes)
%   is built on it. Use eccToPix to position a stimulus away from the centre
%   and degToPix to size it.
%
%   How it works (standard visual-angle geometry, flat screen, eye facing the
%   screen centre, square pixels):
%     1. A point ecc degrees from the line of sight lies
%            posMm = scrDist * tan(ecc)   millimetres from the screen centre.
%     2. One pixel is  scrWidth / scrResX  millimetres wide.
%     3. px = posMm / pixelSizeMm.
%   ecc is measured from the screen centre in any direction (horizontal,
%   vertical or diagonal). A negative ecc gives a negative distance.
%
%   Example: a square stimulus whose width spans 2 degrees, centred 5 degrees
%   from fixation in the direction phi (degrees, counter-clockwise from the
%   right):
%       [xc, yc] = RectCenterd(winRect);
%       r = eccToPix(5, params);                 % centre of the stimulus
%       w = degToPix(2, params, 5, phi);         % its width at that position
%       rect = CenterRectOnPointd([0 0 w w], xc + r * cosd(phi), yc - r * sind(phi));
%   The same size w is used for both sides, so the stimulus is not stretched.
%   (Psychtoolbox counts y downwards, hence the minus sign.)
%
%   Inputs:
%   - ecc:    distance(s) from the screen centre in degrees of visual angle
%             (scalar or array).
%   - params: must contain scrDist (mm), scrWidth (mm) and scrResX (pixels).
%
%   Author
%   Andrea Costantino

% The resolution must come from the parameters: there is no default, because a
% wrong resolution makes every size in degrees wrong.
if ~isfield(params, 'scrResX') || isempty(params.scrResX)
    error('eccToPix:noResolution', ...
        'params.scrResX must be set (scrResXMRI / scrResXPC in parameters.txt).');
end

% The point must lie in front of the eye.
if any(abs(ecc(:)) >= 90)
    error('eccToPix:outOfRange', ...
        'Visual angles must stay below 90 degrees from the screen centre.');
end

% (1) Distance from the screen centre in millimetres
posMm = params.scrDist * tand(ecc);

% (2) Width of one pixel in millimetres
pixelSizeMm = params.scrWidth / params.scrResX;

% (3) Distance in pixels
px = posMm / pixelSizeMm;

end
