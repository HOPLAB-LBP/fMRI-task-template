function imMat = loadImages(trialList, params)
% LOADIMAGES Loads images from a list of filenames and optionally resizes them.
%   imMat = LOADIMAGES(trialList, params) reads images from the list of filenames
%   provided in trialList and returns them in a structure imMat. The function also
%   accepts a params structure that can specify whether to resize the images and 
%   the resizing parameters.
%
%   Input Arguments:
%   - trialList: A struct array containing information about each image file,
%                typically obtained from a list of filenames. Each element in
%                trialList must have a field 'filename' containing the full
%                path to the image file.
%   - params:    A structure containing parameters for image loading and resizing.
%                It must have the field 'resize', a logical value indicating
%                whether to resize the images. If 'resize' is true, it may also
%                contain fields 'outWidth' and 'outHeight' specifying the
%                desired output width and height, respectively.
%
%   Output:
%   - imMat:     A structure containing the loaded images. Each image is stored
%                as a field 'im' in the structure. The field names are indexed
%                according to their position in the trialList.

% Create an empty image structure to hold onto the images
imMat = struct();

% Loop through all the images
for imNum = 1:length(trialList)

    % Find the image file name
    file = trialList(imNum).filename;

    % Read the image
    im = imread(file);

    % If necessary, resize the image
    if params.resize == true
        im = resizeStim(im, params);
    end

    % Add image to the structure
    imMat.image(imNum).im = im;

end

end