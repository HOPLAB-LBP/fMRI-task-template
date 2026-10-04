function px = degToPix(deg, params, ecc, phi, side)
% DEGTOPIX Convert a stimulus size in degrees of visual angle to pixels, using
% the screen geometry in params (selected for the current mode, MRI or PC, by
% parseParameterFile).
%
%   px = degToPix(deg, params)                  stimulus centred on the screen
%   px = degToPix(deg, params, ecc, phi)        stimulus centred ecc degrees
%                                               from the screen centre, in
%                                               direction phi
%   px = degToPix(deg, params, ecc, phi, side)  side = 'width' (default) or
%                                               'height'
%
%   Use this for every size in degrees, and eccToPix to position a stimulus
%   away from the centre.
%
%   What the size means: the visual angle that one side of the stimulus spans
%   at the eye, measured through the stimulus centre. 'width' measures the
%   horizontal side, 'height' the vertical one. For an image, give the size of
%   its longest side and derive the other side from the image's aspect ratio
%   in pixels (as resizeStim does), so the image is never stretched.
%
%   How it works (flat screen, eye facing the screen centre at scrDist mm,
%   square pixels; x to the right, y up, in mm from the screen centre):
%     1. The stimulus centre is at (cx, cy) = scrDist * tan(ecc) *
%        (cos(phi), sin(phi)), exactly ecc degrees from the line of sight
%        (see eccToPix). phi is counter-clockwise from the horizontal axis to
%        the right.
%     2. The width is the segment from (cx - h, cy) to (cx + h, cy). It lies on
%        the line y = cy, whose nearest point to the eye is at
%        D = sqrt(scrDist^2 + cy^2), so it spans
%            deg = atan((cx + h) / D) - atan((cx - h) / D).
%     3. Solving for the half size h, with Q = D^2 + cx^2 and
%        R = sqrt(D^2 + cx^2 * sin(deg)^2):
%            h = Q * sin(deg) / (R + D * cos(deg))    (deg < 90)
%        For the height, swap the roles of cx and cy.
%     4. px = 2 * h / (scrWidth / scrResX).
%   Centred (ecc = 0) this is 2 * scrDist * tan(deg / 2) millimetres, the same
%   for both sides. Off centre the same angle covers more pixels the farther
%   out the stimulus is, and the other side of a square can span a slightly
%   different angle (about 1.5% at 10 degrees from the centre on the
%   horizontal or vertical axis; on a diagonal both sides span the same
%   angle).
%
%   Inputs:
%   - deg:    size(s) in degrees of visual angle, 0 <= deg < 180 (scalar or
%             array).
%   - params: must contain scrDist (mm), scrWidth (mm) and scrResX (pixels).
%   - ecc:    optional, distance of the stimulus centre from the screen centre
%             in degrees of visual angle (scalar, or an array the same size as
%             deg). Default 0.
%   - phi:    optional, direction of the stimulus centre in degrees,
%             counter-clockwise from the horizontal axis to the right (scalar,
%             or an array the same size as deg). Default 0.
%   - side:   optional, 'width' (default) or 'height'.
%
%   Example: an image centred 5 degrees above fixation whose height spans
%   2 degrees:
%       hPx = degToPix(2, params, 5, 90, 'height');
%
%   Author
%   Andrea Costantino

if nargin < 3 || isempty(ecc)
    ecc = 0;
end
if nargin < 4 || isempty(phi)
    phi = 0;
end
if nargin < 5 || isempty(side)
    side = 'width';
end
if any(deg(:) < 0) || any(deg(:) >= 180)
    error('degToPix:outOfRange', 'Sizes must be at least 0 and below 180 degrees.');
end

% (1) Stimulus centre in mm (eccToPix holds the checks on ecc and the
% resolution)
pixelSizeMm = params.scrWidth / params.scrResX;
r = eccToPix(ecc, params) * pixelSizeMm;
cx = r .* cosd(phi);
cy = r .* sind(phi);

% (2) The side's own coordinate (a) and the other one (b)
switch lower(side)
    case 'width'
        a = cx; b = cy;
    case 'height'
        a = cy; b = cx;
    otherwise
        error('degToPix:side', 'side must be ''width'' or ''height''.');
end
D = sqrt(params.scrDist ^ 2 + b .^ 2);
Q = D .^ 2 + a .^ 2;

% (3) Half size in mm. This form avoids tan, so it stays stable near and above
% 90 degrees; at exactly 90 degrees h = sqrt(Q).
S = sind(deg);
C = cosd(deg);
R = sqrt(D .^ 2 + a .^ 2 .* S .^ 2);
h = Q .* S ./ (R + D .* C);
% Bring deg and Q to the size of h (inputs may broadcast, e.g. a row of sizes
% and a column of positions), so the masks below pick the right entries.
deg = deg + zeros(size(h));
Q = Q + zeros(size(h));
above = deg > 90;
if any(above(:))
    hAbove = (R - D .* C) ./ S;
    h(above) = hAbove(above);
end
h(deg == 90) = sqrt(Q(deg == 90));
h(deg == 0) = 0;

% (4) Full size in pixels
px = 2 * h / pixelSizeMm;

end
