function px = degToPix(deg, params)
% DEGTOPIX Convert a size in degrees of visual angle to pixels, using the screen
% geometry in params (selected for the current mode, MRI or PC, by
% parseParameterFile).
%
%   This is the single place that maps degrees to pixels.
%
%   How it works (standard visual-angle geometry, stimulus centred on the
%   screen, square pixels):
%     1. A stimulus subtending `deg` degrees at viewing distance scrDist spans
%            sizeMm = 2 * scrDist * tan(deg / 2)   millimetres on the screen.
%     2. One pixel is  scrWidth / scrResX  millimetres wide.
%     3. px = sizeMm / pixelSizeMm.
%   For a stimulus away from the screen centre the same angle covers more
%   millimetres; convert such stimuli separately if their exact size matters.
%
%   Inputs:
%   - deg:    size(s) in degrees of visual angle (scalar or array).
%   - params: must contain scrDist (mm), scrWidth (mm) and scrResX (pixels).
%
%   Author
%   Andrea Costantino

% The resolution must come from the parameters: there is no default, because a
% wrong resolution makes every size in degrees wrong.
if ~isfield(params, 'scrResX') || isempty(params.scrResX)
    error('degToPix:noResolution', ...
        'params.scrResX must be set (scrResXMRI / scrResXPC in parameters.txt).');
end

% (1) Size on the screen in millimetres
sizeMm = 2 * params.scrDist * tan(deg2rad(deg) / 2);

% (2) Width of one pixel in millimetres
pixelSizeMm = params.scrWidth / params.scrResX;

% (3) Size in pixels
px = sizeMm / pixelSizeMm;

end
