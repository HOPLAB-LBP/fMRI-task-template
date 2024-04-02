%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% fMRI EXPERIMENTAL TASK
%
% some documentation here 
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% CLEANUP & SET MODES

% Clean up the environment
clc; % Clear the Command Window.
close all; % Close all figures (except those of imtool.)
clear; % Clear all variables from the workspace.

% Ensure that the screen gets closed when the script terminates.
cleanObj = onCleanup(@()sca);

% Decide on the debugMode and PC mode
debugMode = true; % debugMode mode flag. Set to false for actual experiment runs.
fmriMode = false; % Computer mode flag. Set to true whenrunning on the fMRI scanner computer.

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

%% IMPORT EXTERNAL PARAMETERS & INITIALISE PTB

% Use the parse parameter function to import all parameters from file
params = parseParameterFile('parameters.txt', fmriMode);

% % This should be removed eventually
% This is a quick fix for mac users: detect the ID of your keyboard
keyboardID = detectKeyboard();
% keyboardID = 23;

% Initialise psychtoolbox (PTB)
% initializePTB();
debugInitializePTB(keyboardID);

%% USER INPUT: SUBJECT & RUN NUMBER

% Declare subject number and decide on the run to start from
if debugMode == true
    % Default values for subject & run number in debug mode
    answer = {'99', '1'};
else
    % Else if in actual experiment mode
    prompt = {'subject number', 'Run number'};
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

%% SETUP A SUBJECT-SPECIFIC RESULTS DIRECTORY

% Prepares a subject- and run-specific directory to store outputs

% Make a directory name with subject number if it doesn't exist yet
in.resDir = fullfile(pwd, 'data', ['sub-' answer{1}]);

% Check if the results directory exists & if we're not in debug mode
if exist(in.resDir, 'dir') == 0 && debugMode == false
    mkdir(in.resDir);
end

%% LOAD TRIAL LIST & IMAGES

% Create a filename to save the future trial list
in.trialListDir = fullfile(in.resDir, ['trial-list-sub-' answer{1} '.tsv']);

% If this file doesn't exist yet, create it
if exist(in.trialListDir, 'file') == 0
    % Create a list of trials based on the input parameters
    trialList = makeTrialList(params, in);
    % Write the trial list as a TSV file if not in debug mode
    if debugMode == 0
        writetable(struct2table(trialList), in.trialListDir , 'Delimiter', '\t', 'FileType', 'text');
    end

% If this file exists, read it
elseif exist(in.trialListDir, 'file') == 2
    % Read the tsv trial list
    trialListData = readtable(in.trialListDir, 'Delimiter', '\t', 'FileType', 'text');
    % Convert it to a structure
    trialList = table2struct(trialListData);
end

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
% fprintf(logFile, 'EVENT_TYPE\tEVENT_NAME\tRUNNUM\tDATETIME\tEXP_ONSET\tACTUAL_ONSET\tDELTA\tEVENT_ID\n');
logEvent(logFile, 'EVENT_TYPE','EVENT_NAME','DATETIME','EXP_ONSET','ACTUAL_ONSET','DELTA','EVENT_ID');

% Embed the rest of the script in a try-catch structure to log errors
try
    %% SCREEN SETUP
    
    % Configure the PTB graphics window based on parameters and debug mode
    [win, winRect, screen, VBLTimestamp] = setupScreen(params, debugMode);
    
    % Store the screen setup time stamp
    in.scriptStart = VBLTimestamp;
    
    % Log the experiment start event with its timestamp
    % fprintf(logFile, 'START\t-\t-\t%s\t-\t%f\t-\t-\n', string(datetime('now', 'Format', 'yyyy-MM-dd HH:mm:ss.SSS')), VBLTimestamp-in.scriptStart);
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
    % Based on the run number find the response button instructions
    respInst1 = unique([runTrials.respInst1]);
    respInst2 = unique([runTrials.respInst2]);
    
    % Extract the images of the run
    runImMat = imMat.image(runTrials(1).trialNb:runTrials(end).trialNb);
    
    %% INSTRUCTIONS
    
    % Generate the run-specific instructions
    displayInstructions(win, params, in, respInst1, respInst2);
    
    % Display them on screen and log it
    [VBLTimestamp, ~, ~, ~] = Screen('Flip', win);
    % Log this event, recording the time at which the instructions were displayed.
    % fprintf(logFile, 'FLIP\tInstr\t%d\t%s\t-\t%f\t-\t-\n', in.runNum, string(datetime('now', 'Format', 'yyyy-MM-dd HH:mm:ss.SSS')), VBLTimestamp - in.scriptStart);
    logEvent(logFile, 'FLIP','Instr', dateTimeStr,'-',VBLTimestamp - in.scriptStart,'-','-');
    
    % Log the key press confirming participant has read the instructions
    conditionFunc = @(x) true; % A placeholder condition function that always returns true.
    % switch back to this function eventually  
    % logKeyPress(params, in, logFile, false, true, conditionFunc);
    % I'm using this function below due to a problem on my laptop
    debugLogKeyPress(params, in, logFile, false, true, conditionFunc, keyboardID);
    
    
    %% TRIGGER WAIT
    
    % Display a message on screen while waiting for the scanner trigger
    DrawFormattedText(win, params.triggerWaitText, 'center', 'center', black);
    
    % Display the message and log it
    [VBLTimestamp, ~, ~, ~] = Screen('Flip', win);
    % Log the screen flip event, indicating that the experiment is in a trigger-wait state
    % fprintf(logFile, 'FLIP\tTgrWait\t%d\t%s\t-\t%f\t-\t-\n', in.runNum, string(datetime('now', 'Format', 'yyyy-MM-dd HH:mm:ss.SSS')), VBLTimestamp - in.scriptStart);
    logEvent(logFile, 'FLIP','TgrWait', dateTimeStr,'-',VBLTimestamp - in.scriptStart,'-','-');
    
    % Record the trigger signal
    % ** We record the trigger twice because of a bug where MR8 sends 2 triggers **
    conditionFunc = @(x) true; % A condition function that always returns true, used here for simplicity.
    % here again, switch back to non-debug function afterwards
    % logKeyPress(params, in, logFile, true, false, conditionFunc); % First call to wait for and log the trigger signal.
    % logKeyPress(params, in, logFile, true, false, conditionFunc); % Second call, if needed, based on your setup.
    debugLogKeyPress(params, in, logFile, true, false, conditionFunc, keyboardID); % First call to wait for and log the trigger signal.
    debugLogKeyPress(params, in, logFile, true, false, conditionFunc, keyboardID); % Second call, if needed, based on your setup.
    
    %% PRE-FIXATION
    
    % Show an initial fixation display
    Screen('FillRect', win, gray); % Fill the screen with gray
    displayFixation(win, winRect, params, in); % Draw the fixation element
    
    % Display the fixation cross and log it
    [VBLTimestamp, ~, ~, ~] = Screen('Flip', win);
    % Log this fixation display event, marking the onset of the fixation period in the experiment log file.
    % fprintf(logFile, 'FLIP\tFix\t%d\t%s\t-\t%f\t-\t-\n', in.runNum, string(datetime('now', 'Format', 'yyyy-MM-dd HH:mm:ss.SSS')), VBLTimestamp - in.scriptStart);
    logEvent(logFile, 'FLIP','Fix', dateTimeStr,'-',VBLTimestamp - in.scriptStart,'-','-');
    
    % Record the trial sequence official starts, immediately after fixation
    runStart = VBLTimestamp;
    % Calculate the time elapsed since the script started
    preRunTime = runStart - in.scriptStart;
    
    % Wait for and log any key presses during the initial fixation period.
    conditionFunc = @(x) (GetSecs - runStart) <= params.prePost; % Define a condition function for the duration of the pre-trial fixation.
    % logKeyPress(params, in, logFile, false, false, conditionFunc); % Call a custom function to log key presses, passing the condition for timing.
    debugLogKeyPress(params, in, logFile, false, false, conditionFunc, keyboardID); % Call a custom function to log key presses, passing the condition for timing.
    
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
        displayTrial(runImMat, i, win, winRect, in);

        % Flip the screen to show the stimulus and log it
        [VBLTimestamp, ~, ~, ~] = Screen('Flip', win);
        % fprintf(logFile, 'FLIP\tStim\t%d\t%s\t%f\t%f\t%f\t%s\n', in.runNum, string(datetime('now', 'Format', 'yyyy-MM-dd HH:mm:ss.SSS')), preRunTime + runTrials(i).idealStimOnset, VBLTimestamp - in.scriptStart, (VBLTimestamp - in.scriptStart) - (preRunTime + runTrials(i).idealStimOnset), runTrials(i).stimuli);
        logEvent(logFile, 'FLIP','Stim', dateTimeStr,preRunTime + runTrials(i).idealStimOnset, VBLTimestamp - in.scriptStart, (VBLTimestamp - in.scriptStart) - (preRunTime + runTrials(i).idealStimOnset),runTrials(i).stimuli);
        
        %% Trial response
        
        % Define a condition to capture responses only during the stimulus duration
        conditionFunc = @(x) (GetSecs - trialStart) <= params.stimDur;
        % Record key presses during the stimulus presentation
        % pressedKey = logKeyPress(params, in, logFile, false, false, conditionFunc); % Capture and log the first key press, if any.
        pressedKey = debugLogKeyPress(params, in, logFile, false, false, conditionFunc, keyboardID); % Capture and log the first key press, if any.

        %% Trial accuracy

        % This is a working zone showing how you can record trial accuracy
        % Fetch the correct key based on the current button mapping
        if strcmp(runTrials(i).setting, 'inside')
            corrKey = respKey1;
        elseif strcmp(runTrials(i).setting, 'outside')
            corrKey = respKey2;
        else
            corrKey = NaN;
        end
        % Calculate accuracy based on the current pressed key
        accuracy = corrKey == pressedKey;
        % Log the accuracy in the console
        fprintf(1, 'Trial %d accuracy = %d\n', i, accuracy);
        
        %% Post-stimulus fixation
        
        % Fill the screen with gray & show the fixation
        Screen('FillRect', win, gray);
        displayFixation(win, winRect, params, in);

        % Flip the screen and log it
        [VBLTimestamp, ~, ~, ~] = Screen('Flip', win);
        % fprintf(logFile, 'FLIP\tFix\t%d\t%s\t-\t%f\t-\t-\n', in.runNum, string(datetime('now', 'Format', 'yyyy-MM-dd HH:mm:ss.SSS')), VBLTimestamp - in.scriptStart);
        logEvent(logFile, 'FLIP','Fix', dateTimeStr, '-', VBLTimestamp - in.scriptStart, '-', '-');
    
        % Record keys during fixation. Here we select only the first response -- i.e., if the subj responded during the stimulus, we don't record this response
        conditionFunc = @(x) (GetSecs - trialStart) <= params.stimDur + fixDur; % Define a condition function for the duration of the post-trial fixation.
        if isempty(pressedKey) % If no key press was recorded during the stimulus presentation,
            pressedKey = logKeyPress(params, in, logFile, false, false, conditionFunc); % attempt to capture responses during the fixation.
            % pressedKey = debugLogKeyPress(params, in, logFile, false, false, conditionFunc, keyboardID); % attempt to capture responses during the fixation.
        else
            % logKeyPress(params, in, logFile, false, false, conditionFunc); % Otherwise, continue to log any additional key presses (first response was already recorded).
            debugLogKeyPress(params, in, logFile, false, false, conditionFunc, keyboardID); % Otherwise, continue to log any additional key presses (first response was already recorded).
        end
    
        % Store the response (if any) in the trial list for later analysis.
        if ~isempty(pressedKey)
            runTrials(i).response = pressedKey; % Update the trial list with the key press identifier.
        end
    end
    
    %% FINAL FIXATION
    
    % Fill the screen with gray to reset the background
    Screen('FillRect', win, gray);
    % Draw the final fixation cross
    displayFixation(win, winRect, params, in);

    % Flip the screen and log it
    [PostFixFlip, ~, ~, ~] = Screen('Flip', win);
    % Log the display of the final fixation cross, marking the end of active stimulus presentation.
    logEvent(logFile, 'FLIP','Fix', dateTimeStr, '-', VBLTimestamp - in.scriptStart, '-', '-');
    
    % Record any key presses during this final fixation period, ensuring all participant responses are captured.
    conditionFunc = @(x) (GetSecs - PostFixFlip) <= params.prePost; % Define the condition based on the duration of the final fixation.
    logKeyPress(params, in, logFile, false, false, conditionFunc); % Capture and log key presses during this period.
    % debugLogKeyPress(params, in, logFile, false, false, conditionFunc, keyboardID); % Capture and log key presses during this period.
    
    % Calculate and log the total duration of the run, providing a measure of the entire trial sequence length.
    runTime = GetSecs - runStart; % Calculate the total time taken for the run.
    % fprintf(logFile, 'RUNTIME\t-\t%d\t%s\t-\t-\t-\t%f\n', in.numRun, string(datetime('now', 'Format', 'yyyy-MM-dd HH:mm:ss.SSS')), runTime); % Log the total run time.
    logEvent(logFile, 'RUNTIME','-', dateTimeStr, '-', VBLTimestamp - in.scriptStart, '-', runTime);

%% CATCH EXCEPTION
catch exception

    % Log the exception if it has been caught
    % Get the full stack trace from the exception object
    stackTrace = getReport(exception, 'extended', 'hyperlinks', 'off');
    
    % Log error message and stack trace to the log file
    % fprintf(logFile, 'ERROR\tErr\t-\t%s\t-\t-\t-\t-\n', string(datetime('now', 'Format', 'yyyy-MM-dd HH:mm:ss.SSS')));
    logEvent(logFile, 'ERROR','Err', dateTimeStr, '-', '-', '-', '-');
    fprintf(logFile, 'Detailed error message:\n%s\n', stackTrace);
    
    % Also display the error message in the MATLAB Command Window
    disp(['Error: ' stackTrace]);

end
%% SAVE AND CLOSE

% Log the end of the run
% fprintf(logFile, 'END\t-\t%d\t%s\t-\t%f\t-\t-\n', in.runNum, string(datetime('now', 'Format', 'yyyy-MM-dd HH:mm:ss.SSS')), GetSecs-in.scriptStart);
logEvent(logFile, 'END','-', dateTimeStr, '-', GetSecs-in.scriptStart, '-', '-');
% Save the relevant data and close PTB objects
SaveAndClose(params, in, 'runTrials', runTrials, 'runImMat', runImMat, 'logFile', logFile);









