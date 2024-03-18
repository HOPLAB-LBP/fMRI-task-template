function [win, winRect] = setupScreen(params, debugMode)
% SETUPSCREEN - Configure the Psychtoolbox graphics window for stimulus presentation.
%
%   [win, winRect] = SETUPSCREEN(params, debugMode) configures the graphics window 
%   for displaying stimuli using Psychtoolbox. Different settings are applied based 
%   on whether the script is in debug mode or not.
%
%   Input arguments:
%   - params: A structure containing parameters for screen setup.
%   - debugMode: A logical scalar indicating whether the script is in debug mode.
%
%   Output arguments:
%   - win: Window handle for the Psychtoolbox graphics window.
%   - winRect: Screen rectangle defining the position and size of the window.
%
%   When in debug mode (debugMode == true):
%   - Sync tests are disabled to prevent Psychtoolbox warnings that may interrupt debugging.
%   - The window size is set to a custom size defined by params.debugWindow, allowing 
%     for a non-fullscreen window for easier debugging.
%   - A window is opened with GUI window decorations (title bar, etc.) for ease of 
%     interaction during debugging.
%
%   When not in debug mode (debugMode == false):
%   - Character listening is enabled to suppress keypresses from showing in MATLAB, 
%     enhancing the cleanliness of experimental presentation.
%   - The mouse cursor is hidden to avoid distractions during stimulus presentation.
%   - Sync tests are disabled to ensure compatibility.
%   - A full-screen window with a black background is opened for the experimental presentation.


% Check for debug mode or not
if debugMode == true
    % In debug mode, disable sync tests to prevent Psychtoolbox warnings that can interrupt debugging.
    Screen('Preference', 'SkipSyncTests', 0);
    screen = max(Screen('Screens')); % Identify the display screen to use, typically the primary monitor.

    % Define the window size explicitly for debug purposes, allowing for a non-fullscreen window
    windowRect = [0 0 params.debugWindow(1) params.debugWindow(2)];% Set the window size to the desired pixel size
    % Open a window on the specified screen, with the defined size and background color
    % The 'kPsychGUIWindow' flag ensures the window appears with GUI window decorations (title bar, etc.).
    [win, winRect] = Screen('OpenWindow', screen, 0, windowRect, [], [], [], [], [], kPsychGUIWindow);

elseif debugMode == false

    % In non-debug mode, prepare the environment for a clean experimental presentation.
    ListenChar(2); % Enable character listening to suppress keypresses showing in MATLAB.
    HideCursor; % Hide the mouse cursor to avoid distractions.
    Screen('Preference', 'SkipSyncTests', 0); % Still disable sync tests for compatibility.
    screen = max(Screen('Screens')); % Again, identify the display screen to use.

    % Open a full-screen window on the specified screen, with a background color of 0 (black).
    [win, winRect] = Screen('OpenWindow', screen, 0);
end


end
