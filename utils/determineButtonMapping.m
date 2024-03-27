function butMap = determineButtonMapping(params, subNum, runNum)
% DETERMINEBUTTONMAPPING Determines the button mapping based on subject and run numbers.
%
%   butMap = DETERMINEBUTTONMAPPING(params, subNum, runNum) calculates the button mapping
%   to be used in an experimental task based on the subject number and the run number. The mapping
%   logic alternates the button mapping across subjects and runs to distribute potential biases evenly.
%   Specifically, it assigns one mapping for even subject numbers with odd run numbers and another
%   mapping for even subject numbers with even run numbers. The opposite assignments apply to odd subject
%   numbers.
%
%   Inputs:
%   - params:     Structure containing parameters required for button mapping. It must contain the fields:
%                 'respKey' - A cell array containing response keys.
%                 'resKeyInstructions' - A cell array containing instructions corresponding to response keys.
%   - subNum:     An integer representing the subject number.
%   - runNum:     An integer representing the run number of the experiment.
%
%   Output:
%   - butMap:     Structure containing button mapping information.
%                 Fields:
%                 'mapNumber' - An integer (1 or 2) indicating the button mapping to be used.
%                 'respKey' - Cell array containing response keys based on the determined mapping.
%                 'respInst' - Cell array containing instructions corresponding to response keys.
%
%   Example:
%   butMap = determineButtonMapping(params, 1, 2); % Returns button mapping based on subject and run numbers.

% Check if the required fields are present in the params structure
requiredFields = {'respKey1','respKey2','respInst1','respInst2'};
missingFields = setdiff(requiredFields, fieldnames(params));
if ~isempty(missingFields)
    error('determineButtonMapping:paramsMissing', 'Required field(s) %s missing in the params structure.', strjoin(missingFields, ', '));
end

% Check if subject number is even
if mod(subNum, 2) == 0
    % For even subject numbers, check run number
    if mod(runNum, 2) == 1
        % If run number is odd, set button mapping to 1
        butMap.mapNumber = 1;
    else
        % If run number is even, set button mapping to 2
        butMap.mapNumber = 2;
    end
else
    % For odd subject numbers, also check run number
    if mod(runNum, 2) == 1
        % If run number is odd, set button mapping to 2
        butMap.mapNumber = 2;
    else
        % If run number is even, set button mapping to 1
        butMap.mapNumber = 1;
    end
end

% Based on the button map from above, switch the response keys or not
if butMap.mapNumber == 1
    butMap.respKey1 = params.respKey1; % Keep the order of response keys
    butMap.respKey2 = params.respKey2;
    butMap.respInst1 = params.respInst1; % Keep the order of response instructions
    butMap.respInst2 = params.respInst2;
elseif butMap.mapNumber == 2
    butMap.respKey1 = params.respKey2; % Reverse the order of response keys
    butMap.respKey2 = params.respKey1;
    butMap.respInst1 = params.respInst2; % Reverse the order of response instructions
    butMap.respInst2 = params.respInst1;
end

end
