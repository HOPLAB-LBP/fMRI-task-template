function px = degToPix(deg, params, ecc)
% DEGTOPIX Convert a size in degrees of visual angle to pixels, using the screen
% geometry in params (selected for the current mode, MRI or PC, by
% parseParameterFile).
%
%   px = degToPix(deg, params)       stimulus centred on the screen
%   px = degToPix(deg, params, ecc)  stimulus centred ecc degrees away from
%                                    the screen centre, in any direction
%
%   Use this for every size in degrees, and eccToPix to position a stimulus
%   away from the centre. Both use the same geometry (in eccToPix).
%
%   How it works: the stimulus spans from ecc - deg/2 to ecc + deg/2 degrees,
%   so its size is the distance between its two edges on the screen:
%       px = eccToPix(ecc + deg/2) - eccToPix(ecc - deg/2)
%   that is, scrDist * (tan(ecc + deg/2) - tan(ecc - deg/2)) millimetres
%   divided by the pixel size (scrWidth / scrResX). With ecc = 0 (the default)
%   this is 2 * scrDist * tan(deg / 2) millimetres. Off centre, the size is
%   measured along the line from the screen centre through the stimulus
%   centre, and the same angle covers more pixels the farther out it is.
%
%   Never stretch a stimulus: scale the whole image with one size. For a
%   non-square image, convert one side and derive the other from the image's
%   aspect ratio in pixels (as resizeStim does). Off centre this is an
%   approximation: the size is exact along the line from the screen centre,
%   while in other directions the same pixels span up to 1/cos(ecc) times
%   more degrees (+0.4% at 5, +1.5% at 10, +6.4% at 20 degrees from the
%   centre). Correcting that would mean stretching the image on the screen.
%
%   Inputs:
%   - deg:    size(s) in degrees of visual angle (scalar or array).
%   - params: must contain scrDist (mm), scrWidth (mm) and scrResX (pixels).
%   - ecc:    optional, distance of the stimulus centre from the screen
%             centre in degrees of visual angle (scalar, or an array the same
%             size as deg). Default 0.
%
%   Author
%   Andrea Costantino

if nargin < 3 || isempty(ecc)
    ecc = 0;
end

px = eccToPix(ecc + deg / 2, params) - eccToPix(ecc - deg / 2, params);

end
