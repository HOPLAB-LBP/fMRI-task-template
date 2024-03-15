function butMap = determineButtonMapping(params, subNum, runNum)
% determineButtonMapping Determines the button mapping based on subject and run numbers.
%
% This function calculates the button mapping to be used in an experimental
% task based on the subject number and the run number. The mapping logic is
% designed to alternate the button mapping across subjects and runs to
% distribute potential biases evenly. Specifically, it assigns one mapping
% for even subject numbers with odd run numbers and another mapping for
% even subject numbers with even run numbers, and the opposite assignments
% for odd subject numbers.
%
% Inputs:
%   subNum - An integer representing the subject number.
%   runNum - An integer representing the run number of the experiment.
%
% Output:
%   butMap - An integer (1 or 2) indicating the button mapping to be used.
%
% Example usage:
%   butMap = determineButtonMapping(1, 2); % Might return 1 or 2 based on the logic.
%
% Andrea Costantino, [9/6/23]


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
    butMap.respKey = params.respKey; % Keep the order of response keys
    butMap.respInst = params.resKeyInstructions; % Keep the order of response instructions
elseif butMap.mapNumber == 2
    butMap.respKey = fliplr(params.respKey); % Reverse the order of response keys
    butMap.respInst = fliplr(params.resKeyInstructions); % Reverse the order of response instructions
end

end
