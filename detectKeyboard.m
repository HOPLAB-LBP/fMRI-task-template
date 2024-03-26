function keyboardID = detectKeyboard()
% This is a debug function I use for trying to record button presses

% Start by clearing up
close all;
clc;

% Turn off character echo for the time of the function
ListenChar(0);

% Retrieve any devices connected to the computer using Psychtoolbox
Devices=PsychHID('Devices');

% Start an empty list with potential detected keyboards
keyboardsIDs = [];

% Iterate over the devices and check if they are keyboards
for iiD = 1:numel(Devices)
    try
        % Try to create a start a keyboard queue with the device
        KbQueueCreate(Devices(iiD).index);
        KbQueueStart(Devices(iiD).index);
        % If successful, add the device to the Kb list
        keyboardsIDs(end+1,1) = Devices(iiD).index;
    end
end

% Loop over the potential keyboards and check if they register key presses
stopScript = 0;
disp('Press any key now to check for working keyboard devices.')
while ~stopScript
    % Loop over the keyboard devices
    for iiD = 1:numel(keyboardsIDs)
        % Register any potential key press
        [keyIsDown, firstPress]=KbQueueCheck(keyboardsIDs(iiD));
        % If a key was actually detected, go ahead and save the device
        if keyIsDown
            % Save the working keyboard
            keyboardID = iiD;
            % Print some feedback on the detection
            fprintf('keyisdown detected with keyboardID # %d\n Press ''a'' to stop', keyboardsIDs(iiD));
            % Report the ID of the key that was pressed
            keyID = find(firstPress);
            disp(keyID);
            if any(keyID == 20), stopScript =1; end
        end
    end
end

% Stop the initiated queues to clean up
for iiD = 1:numel(keyboardsIDs)
    KbQueueStop(keyboardsIDs(iiD));
end

% Turn character echo back on
ListenChar();

end