KbName('UnifyKeyNames');
    
% Create a queue for keyboard events
KbQueueCreate(26);

% Start recording keyboard events
KbQueueStart(26);

firstPressedKey = []; % Initialize return value

% flush keyboard queue
KbQueueFlush;
% close all;
% clc;
oui = true;
% start logging loop
while oui == true
    
    [pressed, firstPress] = KbQueueCheck(26); % check keyboard queue
    disp(KbName(firstPress));
    KbQueueFlush;
    
    % if pressed
    %     oui = false
    % end

end
   
while oui == true
    keyCode = find(firstPress); % find the first key that was pressed

    % log the trigger key
    if pressed && firstPress(params.triggerKey)
        fprintf(logFile, 'PULSE\tTrigger\t%d\t%s\t-\t%f\t-\t%d\n', in.runNum, char(datetime('now', 'Format', 'yyyy-MM-dd HH:mm:ss.SSS')), GetSecs-in.scriptStart, keyCode);
        if triggerKeyBreaks
            break
        end

        % log and return if the escape key is pressed
    elseif pressed && firstPress(params.escapeKey)
        fprintf(logFile, 'RESP\tEscape\t%d\t%s\t-\t%f\t-\t%d\n', in.runNum, char(datetime('now', 'Format', 'yyyy-MM-dd HH:mm:ss.SSS')), GetSecs-in.scriptStart, keyCode);
        in.pressedAbortKey = true; % Assign the pressed key
        %break
        error('ScriptExecution:ManuallyAborted', 'Script execution manually aborted.');

        % log any other key press and break if the condition is met
    elseif pressed
        fprintf(logFile, 'RESP\tKeyPress\t%d\t%s\t-\t%f\t-\t%d\n', in.runNum, char(datetime('now', 'Format', 'yyyy-MM-dd HH:mm:ss.SSS')), GetSecs-in.scriptStart, keyCode);
        if isempty(firstPressedKey) && any(keyCode == p.respKey) % Check if firstPressedKey is still empty and pressed key is in respKey array
            firstPressedKey = keyCode; % Assign the pressed key
        end
        if otherKeysBreak
            break
        end
    end
end

desiredManufacturer = 'Apple Inc.';

for idx = 1:numel(Devices)
    disp(Devices(idx).product)
    % Check if the 'manufacturer' field matches the desired value
    % if strcmp(Devices(idx).manufacturer, desiredManufacturer)
    %     % If found, display the index
    %     disp(['Index where manufacturer is ', desiredManufacturer, ': ', num2str(idx)]);
    % end
end


