function [firstPressedKey, in] = logKeyPress(params, in, logFile, triggerKeyBreaks, otherKeysBreak, conditionFunc)
% LOGKEYPRESS - Function for logging key press
% 
%   This function logs key press events and writes to logFile. It continues
%   until the conditionFunc returns true, or when the specific key events occur.
%   The function logs either a meaningful key name (in most cases), or an
%   integer (in case of escape key or trigger key) corresponding to the key code
%   of the first pressed key. It also returns a meaningful key name if the first
%   pressed key is included in the array params.respKey (i.e., if the key pressed
%   is one of the assigned keys for the task).
%
%   Args:
%    params (struct): A structure containing key codes.
%    in (struct): A structure containing script start time and other information.
%    logFile (file): The file to write logs to.
%    triggerKeyBreaks (logical, optional): Whether pressing the trigger key breaks the loop.
%    otherKeysBreak (logical, optional): Whether pressing any key other than the trigger or escape key breaks the loop.
%    conditionFunc (function, optional): The function to evaluate for loop exit.
%
%   Example:
%    [firstPressedKey, in] = logKeyPress(p, logFile, in, true, false, @(keyCode) keyCode <= 4)
%    [~, in] = logKeyPress(p, logFile, in, true, false, @(x) true) i.e., the loop continues indefinitely unless a key event breaks it.
% 
%   Author
%   Andrea Costantino [16/6/23]

firstPressedKey = []; % Initialize return value

% flush keyboard queue
KbQueueFlush;

% start logging loop
while conditionFunc(true)
    
    [pressed, firstPress] = KbQueueCheck(); % check keyboard queue
    
    keyCode = find(firstPress); % find the first key that was pressed

    % log the trigger key
    if pressed && firstPress(params.triggerKey)
        logEvent(logFile, 'PULSE', 'Trigger', dateTimeStr, '-', GetSecs-in.scriptStart, '-', keyCode);
        if triggerKeyBreaks
            break
        end

        % log and return if the escape key is pressed
    elseif pressed && firstPress(params.escapeKey)
        logEvent(logFile, 'RESP', 'Escape', dateTimeStr, '-', GetSecs-in.scriptStart, '-', keyCode);
        in.pressedAbortKey = true; % Assign the pressed key
        %break
        error('ScriptExecution:ManuallyAborted', 'Script execution manually aborted.');

        % log any other key press and break if the condition is met
    elseif pressed
        % Turn the keycode into a meaningful key name
        keyName = KbName(keyCode);
        % Log this more meaningful key name
        logEvent(logFile, 'RESP', 'KeyPress', dateTimeStr, '-', GetSecs-in.scriptStart, '-', keyName);
        % If the key was one of the expected keys, return it
        if isempty(firstPressedKey) && any(ismember(KbName(keyCode), in.respKeys))
            firstPressedKey = keyName; % Assign the pressed key
        end
        % If other keys break is useful to pass screens like instructions
        if otherKeysBreak
            break
        end
    end
end

end
