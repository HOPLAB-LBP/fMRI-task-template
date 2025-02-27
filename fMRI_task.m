%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% fMRI EXPERIMENTAL TASK
%
% This is a template task to run an fMRI experiment. Use it as a base to
% write your own experimental script.
% 
% The template implements a simple binary classification task where
% participants are prompted to report if images show an inside or an
% outside scene. 
% 
% Make sure to set the debugMode and fmriMode flags to the values you need
% before running this script.
%  - Turn 'debugMode' on to run the task in a window rather than full
%    screen, and to avoid saving results.
%  - Turn 'fmriMode' on to read the scanner trigger and response buttons,
%    and use the scanner screen distance and width properties.
%  - Turn on the 'macMode' if you're running this script on a mac.
% 
% The structure & most of the ideas for this script are from previous code 
% from Andrea Costantino & Laura Van Hove. It was adapted to a general
% template by Tim Maniquet.
% 
% Authors
% Andrea Costantino, Laura Van Hove [9/6/23]
% 
% Last updated
% Tim Maniquet [22/4/24]
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% CLEANUP & SET MODES

% Clean up the environment
clc; % Clear the Command Window.
close all; % Close all figures (except those of imtool.)
clear; % Clear all variables from the workspace.

% Ensure that the screen gets closed when the script terminates.
cleanObj = onCleanup(@()sca);

% Decide on the debugMode and PC mode
debugMode = false; % debugMode mode flag. Set to false for actual experiment runs.
fmriMode = false; % Computer mode flag. Set to true whenrunning on the fMRI scanner computer.

% If you're running on mac, use this flag
macMode = true;

%% CHECK AND SET WORKING DIRECTORY

% Declare default directories for the source and utilities
defaultUtilsDir = './utils';
defaultSrcDir = './src';

% Check if the default utility directory exists
while ~exist(defaultUtilsDir, 'dir')
    disp(['Utility directory "', defaultUtilsDir, '" does not exist.']);
    % Prompt the user to input the utility directory
    utilsDir = input('Please provide the path to the utility directory: ', 's');
    defaultUtilsDir = utilsDir;
end

% Check if the default source directory exists
while ~exist(defaultSrcDir , 'dir')
    disp(['Source directory "', defaultSrcDir , '" does not exist.']);
    % Prompt the user to input the source directory
    srcDir  = input('Please provide the path to the source directory: ', 's');
    defaultSrcDir  = srcDir;
end

% Add both directories to the MATLAB path once we're sure they exist
addpath(defaultSrcDir );
addpath(defaultUtilsDir); 
disp('Directories have been added to the MATLAB path.');

%% IMPORT EXTERNAL PARAMETERS

% Use the parse parameter function to import all parameters from file
params = parseParameterFile('parameters.txt', fmriMode);

%% USER INPUT: SUBJECT & RUN NUMBER

% Declare subject number and decide on the run to start from
if debugMode == true
    % Default values for subject & run number in debug mode
    answer = {'99', '1'};
else
    % Else if in actual experiment mode
    prompt = {'subject number', sprintf('Run number (out of %d)', params.numRuns)};
    % Define empty default answers
    def = {'', ''};
    % Collect user input
    answer = inputdlg(prompt,'',1,def);
end

% Store the subject & run number in the 'input' structure
in.subNum = str2double(answer{1});
in.runNum = str2double(answer{2});

% Save a timestamp in the input parameters
in.timestamp = string(datetime('now', 'Format', 'yyyy-MM-dd_HHmmss'));

%% INITIALISE PSYCHOTOOLBOX

% Initialise psychtoolbox (PTB)
if macMode == true
    % This is a quick fix for mac users: detect the ID of your keyboard
    keyboardID = detectKeyboard();
    % Then use this keyboardID to initialise the keyboard
    macInitializePTB(keyboardID);
else
    initializePTB();
end

%% SETUP A SUBJECT-SPECIFIC RESULTS DIRECTORY

% Prepares a subject- and run-specific directory to store outputs

% Make a directory name with subject number if it doesn't exist yet
in.resDir = fullfile(pwd, 'data', ['sub-' zeroFill(answer{1}, 2)]);

% Check if the results directory exists & if we're not in debug mode
if exist(in.resDir, 'dir') == 0 && debugMode == false
    mkdir(in.resDir);
end

%% LOAD TRIAL LIST & IMAGES

% From the parameters (including the list of stimuli), make a trial list
trialList = makeTrialList(params, in);

% From the trial list and parameters, load the images
imMat = loadImages(trialList, params);

%% START LOGGING

% Determine the logging destination based on the debugMode mode
if debugMode == true
    % Log in the command window ('1')
    logFile = 1;
else
    % Create a new run- and subject-dependent log file
    logFile = createLogFile(params, in);
end

% Write the header row to the log file, including variable names
logEvent(logFile, 'EVENT_TYPE','EVENT_NAME','DATETIME','EXP_ONSET','ACTUAL_ONSET','DELTA','EVENT_ID');

% Embed the rest of the script in a try-catch structure to log errors
try
    %% SCREEN SETUP
    
    % Configure the PTB graphics window based on parameters and debug mode
    [win, winRect, screen, VBLTimestamp] = setupScreen(debugMode);
    
    % Store the screen setup time stamp
    in.scriptStart = VBLTimestamp;
    
    % Log the experiment start event with its timestamp
    logEvent(logFile, 'START','-',dateTimeStr,'-',VBLTimestamp-in.scriptStart,'-','-');

    % Define white, gray, black colours based on the screen
    [white, gray, black] = configScreenCol(screen);
    % Add these values to the input parameters
    in.white = white; in.gray = gray; in.black = black;

    % Turn the screen to gray
    Screen(win, 'fillrect', gray);
    
    % Store the pixels per degree value for use in the setup
    in.PPD = convertVisualUnits(1, 'deg', 'px');
   
    %% RUN-SPECIFIC PARAMETERS
    
    % Extract the trials of the run
    runTrials = trialList([trialList.run] == in.runNum);
    
    % Based on the run number find the response buttons
    respKey1 = unique([runTrials.respKey1]);
    respKey2 = unique([runTrials.respKey2]);
    % List all the response keys and append them to the parameters
    params.respKeys = [respKey1, respKey2]; % add any value needed in here

    % Based on the run number find the response button instructions
    respInst1 = unique({runTrials.respInst1});
    respInst2 = unique({runTrials.respInst2});
    
    % Extract the images of the run
    runImMat = imMat.image(runTrials(1).trialNb:runTrials(end).trialNb);
    
    %% INSTRUCTIONS
    
    % Generate the run-specific instructions
    displayInstructions(win, params, in, respInst1, respInst2);
    
    % Display them on screen and log it
    [VBLTimestamp, ~, ~, ~] = Screen('Flip', win);
    % Log this event, recording the time at which the instructions were displayed
    logEvent(logFile, 'FLIP','Instr', dateTimeStr,'-',VBLTimestamp - in.scriptStart,'-','-');
    
    % Anonymous function that always returns true
    conditionFunc = @(x) true; 
    
    % Log the key press confirming participant has read the instructions
    if macMode == true
        macLogKeyPress(params, in, logFile, false, true, conditionFunc, keyboardID);
    else
        logKeyPress(params, in, logFile, false, true, conditionFunc);    
    end    
    
    %% TRIGGER WAIT
    
    % Display a message on screen while waiting for the scanner trigger
    DrawFormattedText(win, params.triggerWaitText, 'center', 'center', black);
    
    % Display the message and log it
    [VBLTimestamp, ~, ~, ~] = Screen('Flip', win);
    % Log the screen flip event, indicating that the experiment is in a trigger-wait state
    logEvent(logFile, 'FLIP','TgrWait', dateTimeStr,'-',VBLTimestamp - in.scriptStart,'-','-');
    
    % Anonymous function that always returns true
    conditionFunc = @(x) true;

    % Record the trigger signal
    % ** We record the trigger twice because of a bug where MR8 sends 2 triggers **
    if macMode == true
        macLogKeyPress(params, in, logFile, true, false, conditionFunc, keyboardID); % First call to wait for and log the trigger signal.
        macLogKeyPress(params, in, logFile, true, false, conditionFunc, keyboardID); % Second call, if needed, based on your setup.
    else
        logKeyPress(params, in, logFile, true, false, conditionFunc); % First call to wait for and log the trigger signal.
        logKeyPress(params, in, logFile, true, false, conditionFunc); % Second call, if needed, based on your setup.
    end
    
    %% PRE-FIXATION
    
    % Show an initial fixation display
    Screen('FillRect', win, gray); % Fill the screen with gray
    displayFixation(win, winRect, params, in); % Draw the fixation element
    
    % Display the fixation cross and log it
    [VBLTimestamp, ~, ~, ~] = Screen('Flip', win);
    % Log this fixation display event, marking the onset of the fixation period in the experiment log file.
    logEvent(logFile, 'FLIP','Pre-fix', dateTimeStr,'-',VBLTimestamp - in.scriptStart,'-','-');
    
    % Record the trial sequence official starts, immediately after fixation
    runStart = VBLTimestamp;
    % Calculate the time elapsed since the script started
    preRunTime = runStart - in.scriptStart;
    
    % Anonymous function to wait for the duration of the pre-trial fixation
    conditionFunc = @(x) (GetSecs - runStart) <= params.prePost;

    % Wait for and log any key presses during the fixation period
    if macMode == true
        macLogKeyPress(params, in, logFile, false, false, conditionFunc, keyboardID);
    else
        logKeyPress(params, in, logFile, false, false, conditionFunc);
    end
    
    %% TRIAL LOOP
    
    % Loop through the run trials, presenting stimuli and recording responses
    for i = 1:length(runTrials)
        %% Trial timing
        
        % Record the start time of the current trial for timing calculations
        trialStart = GetSecs;

        % Calculate and store the onset time (relative to the pre-stim fixation block)
        runTrials(i).stimOnset = trialStart - runStart;

        % Adjust fixation duration based on the timing of this trial relative to its scheduled time.
        fixDur = adjustFixationDuration(runTrials, i, params);
    
        %% Stimulus presentation
        
        % Display the stimulus on screen based on the displayTrial function
        displayTrial(params, in, runImMat, i, win, winRect);

        % Flip the screen to show the stimulus
        [VBLTimestamp, ~, ~, ~] = Screen('Flip', win);

        % Calculate actual onset and difference with ideal onset
        idealStimOnset = preRunTime + runTrials(i).idealStimOnset;
        actualStimOnset = VBLTimestamp - in.scriptStart;
        
        % Log the event with onset values and store it in the trial list
        logEvent(logFile, 'FLIP','Stim', dateTimeStr,idealStimOnset, actualStimOnset, ...
            actualStimOnset - idealStimOnset, runTrials(i).stimuli);
        
        % Store the ideal and the actual onset values in the trial list
        runTrials(i).idealStimOnset = idealStimOnset;
        runTrials(i).stimOnset = actualStimOnset;
        
        %% Trial response
        
        % Anonymous function to wait for the duration of the stimulus duration
        conditionFunc = @(x) (GetSecs - trialStart) <= params.stimDur;
        
        % Record key presses during the stimulus presentation
        if macMode == true
            pressedKey = macLogKeyPress(params, in, logFile, false, false, conditionFunc, keyboardID);
        else
            pressedKey = logKeyPress(params, in, logFile, false, false, conditionFunc);
        end

        % Store the response in the trial list structure
        runTrials(i).response = pressedKey;
        
        %% Post-stimulus fixation
        
        % Fill the screen with gray & show the fixation
        Screen('FillRect', win, gray);
        displayFixation(win, winRect, params, in);

        % Flip the screen and log it
        [VBLTimestamp, ~, ~, ~] = Screen('Flip', win);
        logEvent(logFile, 'FLIP','Fix', dateTimeStr, '-', VBLTimestamp - in.scriptStart, '-', '-');
    
        % Anonymous function to wait for the duration of the post-trial fixation
        conditionFunc = @(x) (GetSecs - trialStart) <= params.stimDur + fixDur;
        
        % Record key presses during fixation. Here we select only the first response
        % If the subj responded during the stimulus, we don't record this response
        if isempty(pressedKey) % If no key press was recorded during the stimulus presentation,
            % attempt to capture responses during the fixation.
            if macMode == true
                pressedKey = macLogKeyPress(params, in, logFile, false, false, conditionFunc, keyboardID);
            else
                pressedKey = logKeyPress(params, in, logFile, false, false, conditionFunc);
            end
        else
            % Otherwise, continue to log any additional key presses (first response was already recorded).
            if macMode == true
                macLogKeyPress(params, in, logFile, false, false, conditionFunc, keyboardID);
            else
                logKeyPress(params, in, logFile, false, false, conditionFunc);
            end
        end
    
        % Store the response (if any) in the trial list for later analysis.
        if ~isempty(pressedKey)
            runTrials(i).response = pressedKey; % Update the trial list with the key press identifier.
        end

        %% Trial accuracy

        % % This is a working zone showing how you can record trial accuracy
        % % It is commented out by default; uncommented it to see the demo
        % % Fetch the correct key based on the current button mapping
        % if strcmp(runTrials(i).setting, 'inside')
        %     corrKey = respKey1;
        % elseif strcmp(runTrials(i).setting, 'outside')
        %     corrKey = respKey2;
        % else
        %     corrKey = NaN;
        % end
        % % Calculate accuracy based on the current pressed key
        % accuracy = corrKey == pressedKey;
        % % Log the accuracy in the console
        % fprintf(1, 'Trial %d accuracy = %d\n', i, accuracy);

    end
    
    %% FINAL FIXATION
    
    % Fill the screen with gray to reset the background
    Screen('FillRect', win, gray);
    % Draw the final fixation cross
    displayFixation(win, winRect, params, in);

    % Flip the screen and log it
    [PostFixFlip, ~, ~, ~] = Screen('Flip', win);
    % Log the display of the final fixation cross, marking the end of active stimulus presentation.
    logEvent(logFile, 'FLIP','Post-fix', dateTimeStr, '-', PostFixFlip - in.scriptStart, '-', '-');
    
    % Anonymous function to wait for the duration of the final fixation
    conditionFunc = @(x) (GetSecs - PostFixFlip) <= params.prePost;

    % Record any key presses during this final fixation period, ensuring all participant responses are captured
    if macMode == true
        macLogKeyPress(params, in, logFile, false, false, conditionFunc, keyboardID);
    else
        logKeyPress(params, in, logFile, false, false, conditionFunc);
    end
    
    % Calculate and log the total duration of the run, providing a measure of the entire trial sequence length.
    runTime = GetSecs - runStart; % Calculate the total time taken for the run.
    logEvent(logFile, 'RUNTIME','-', dateTimeStr, '-', GetSecs - in.scriptStart, '-', runTime);

%% CATCH EXCEPTION
catch exception

    % Log the exception if it has been caught
    % Get the full stack trace from the exception object
    stackTrace = getReport(exception, 'extended', 'hyperlinks', 'off');
    
    % Log error message and stack trace to the log file
    logEvent(logFile, 'ERROR','Err', dateTimeStr, '-', '-', '-', '-');
    fprintf(logFile, 'Detailed error message:\n%s\n', stackTrace);
    
    % Also display the error message in the MATLAB Command Window
    disp(['Error: ' stackTrace]);

end
%% SAVE AND CLOSE

% Log the end of the run
logEvent(logFile, 'END','-', dateTimeStr, '-', GetSecs-in.scriptStart, '-', '-');

% Save the relevant data and close PTB objects
saveAndClose(params, in, debugMode, runTrials, runImMat, logFile);




