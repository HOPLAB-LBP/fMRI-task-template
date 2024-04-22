function imMat = loadImages(trialList, params)
% LOADIMAGES Loads images from a list of filenames and optionally resizes them.
%
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
%
%   Details:
%   - If image resizing is enabled (params.resize == true), the function resizes
%     each image according to the specified output width and height (params.outWidth,
%     params.outHeight). The resized images are stored in the 'im' field of the
%     output structure.
%   - Additionally, the function retrieves the actual pixel width and height of
%     each image and saves them in the params structure under the fields 'imWidth'
%     and 'imHeight', respectively. These values can be useful for further processing
%     or analysis.
%
%   Example:
%   trialList(1).filename = 'image1.jpg';
%   trialList(2).filename = 'image2.jpg';
%   params.resize = true;
%   params.outWidth = 200;
%   params.outHeight = 150;
%   imMat = loadImages(trialList, params);
% 
%   Author
%   Tim Maniquet [12/3/24]

% Check if the required fields are present in the params structure
requiredFields = {'resize'};
missingFields = setdiff(requiredFields, fieldnames(params));
if ~isempty(missingFields)
    error('loadImages:paramsMissing', 'Required field(s) %s missing in the params structure.', strjoin(missingFields, ', '));
end


% Create an empty image structure to hold onto the images
imMat = struct();

% Loop through all the images
for imNum = 1:length(trialList)

    % Find the image file name in the 'stimuli' field
    file = trialList(imNum).stimuli;

    % Check if the trial is a fixation trial or not
    if strcmp(file,'fixation')
        imMat.image(imNum).im = 'fixation';

    else
        % If not a fixation trial, read the image normally
        im = imread(file);
    
        % If necessary, resize the image
        if params.resize == true
            im = resizeStim(im, params);
        end
    
        % Add image to the structure
        imMat.image(imNum).im = im;
    end

end

% Save the actual pixel width and height of the image
[imHeight, imWidth, ~] = size(im); % extract the height and width
params.imHeight = imHeight; % save the image height
params.imWidth = imWidth; % save the image width

end