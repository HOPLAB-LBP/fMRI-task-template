function displayInstructions(win, params, in, respInst1, respInst2)
% DISPLAYINSTRUCTIONS Displays instructions on the screen.
%
%   DISPLAYINSTRUCTIONS(WIN, PARAMS, BUTMAP) displays instructions on the
%   specified PTB window (WIN) using the parameters (PARAMS) and button
%   mapping (BUTMAP) provided. The function extracts instruction text
%   fields from the PARAMS structure, replaces placeholders with button
%   mapping values, merges the instruction sentences into a single
%   paragraph, and draws the paragraph centered on the screen.
%
%   Input Arguments:
%   - win: PTB window pointer.
%   - params: Structure containing parameters for configuring the
%     instructions display. It must contain fields with instruction text,
%     where each field name contains the substring 'instructionsText'.
%   - in: inputs containing the 'black' field, with the screen-based CLUT
%     value of the black color to use in the text.
%   - respInst: Array containing instruction values corresponding to the
%     buttons to use. These values will replace the placeholders in the 
%     instruction text.
%
%   Example:
%   % Define parameters and button mapping
%   params.instructionsText1 = 'Press button () to continue.';
%   params.instructionsText2 = 'Press button () to proceed.';
%   butMap = [1 2]; % Button mapping values
%
%   % Display instructions
%   displayInstructions(win, params, butMap);
% 
%   Author
%   Tim Maniquet [21/3/24]

% Check if the required fields are present in the 'params' structure
requiredFields = {'textSize', 'textFont', 'instructionsText1'};
missingFields = setdiff(requiredFields, fieldnames(params));
if ~isempty(missingFields)
    error('displayInstructions:paramsMissing', 'Required field(s) %s missing in the params structure.', strjoin(missingFields, ', '));
end

% Check if the required fields are present in the 'in' structure
requiredFields = {'black'};
missingFields = setdiff(requiredFields, fieldnames(in));
if ~isempty(missingFields)
    error('displayInstructions:paramsMissing', 'Required field(s) %s missing in the in structure.', strjoin(missingFields, ', '));
end

% Configure text size and font parameters
Screen('TextSize', win, params.textSize);
Screen('TextFont', win, params.textFont);

% Start by extracting the instruction fields from the parameters
% Get field names of params structure
paramFieldnames = fieldnames(params);

% Initialize cell array to store fields containing 'instructions'
instructionTexts = {};

% Iterate through each field name
for i = 1:numel(paramFieldnames)
    % Get current field name
    fieldName = paramFieldnames{i};
    
    % Check if the field name contains 'instructions'
    if contains(fieldName, 'instructionsText')
        % Add content of the field to instructionFields
        instructionTexts{end+1} = params.(fieldName);
    end
end

% Merge the instruction sentences into a single paragraph
% Initialize an empty string to store the combined instruction text
instructionParagraph = '';

% Loop through each instruction text field and add it to the paragraph
for i = 1:numel(instructionTexts)
    % Concatenate the current instruction text field with the instructionParagraph
    instructionParagraph = [instructionParagraph instructionTexts{i} '\n\n'];
end


% Find the place holders and insert the correct buttons where relevant
% Find the occurrences of the placeholder '()'
idx = strfind(instructionParagraph, '()');

% Make an array of response instructions to index from
respInst = {respInst1, respInst2};

% Loop through the place holder positions and replace them
for i = 1:numel(idx)
    % Convert the cell content to a string
    respStr = char(respInst{i});

    % Replace the placeholder with the corresponding value from respStr
    instructionParagraph = [instructionParagraph(1:idx(i)-1), respStr, instructionParagraph(idx(i)+2:end)];

    % Update the next index in case the paragraph changed size
    idx(i+1:end) = strfind(instructionParagraph, '()');
end

% Draw the instruction paragraph in black, centered on the screen
DrawFormattedText(win, instructionParagraph, 'center', 'center', in.black);

end
