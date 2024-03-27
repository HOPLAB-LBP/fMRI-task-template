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
% keyboardID = detectKeyboard();
keyboardID = 23;

% Initialise psychtoolbox (PTB)
% initializePTB();
debugInitializePTB(23);

%% USER INPUT: SUBJECT NUMBER

% Declare subject number and decide on the run to start from
if debugMode == true
    answer = {'99'}; % Default values for subject number in debugMode mode
    % in.butMap = 1; % Default button mapping in debugMode mode
else
    % Else if in actual experiment mode
    prompt = {'subject number'};
    def = {''};
    answer = inputdlg(prompt,'',1,def);
end

% Store the subject number in the 'input' parameters structure
in.subNum = str2double(answer{1});

% Save a timestamp in the input parameters
in.timestamp = string(datetime('now', 'Format', 'yyyy-MM-dd_HHmmss'));

%% SETUP RESULTS DIRECTORY

% Prepares a subject-specific results directory to store outputs

% Construct the path to the results directory for the current subject.
% The directory name includes the subject identifier (e.g., 'sub-1') to separate data by subject.
resDir = fullfile(pwd, 'data', ['sub-' answer{1}]);
in.resDir = resDir; % Store the constructed path in the 'in' structure for later use.

% Check if the results directory exists & if we're not in debugMode mode
if exist(resDir, 'dir') == 0 && debugMode == false
    mkdir(resDir);
end

%% LOAD TRIAL LIST & IMAGES

% Create a list of trials based on the input parameters
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
fprintf(logFile, 'EVENT_TYPE\tEVENT_NAME\tRUNNUM\tDATETIME\tEXP_ONSET\tACTUAL_ONSET\tDELTA\tEVENT_ID\n');

%% SCREEN SETUP

% Set up the PTB screen, in a try-catch structure to log errors
try
    % Configure the PTB graphics window based on parameters and debug mode
    [win, winRect, screen, VBLTimestamp] = setupScreen(params, debugMode);
    
    % Store the screen setup time stamp
    in.scriptStart = VBLTimestamp;
    
    % Log the experiment start event with its timestamp
    fprintf(logFile, 'START\t-\t-\t%s\t-\t%f\t-\t-\n', string(datetime('now', 'Format', 'yyyy-MM-dd HH:mm:ss.SSS')), VBLTimestamp-in.scriptStart);
    
    % Define white, gray, black colours based on the screen
    [white, gray, black] = configScreenCol(screen);
    % Add these values to the input parameters
    in.white = white; in.gray = gray; in.black = black;

    % Turn the screen to gray
    Screen(win, 'fillrect', gray);
    
    % Store the pixels per degree value for use in the setup
    in.PPD = convertVisualUnits(1, 'deg', 'px');

catch exception

    % Log the exception if it has been caught
    logError(logFile, exception);

end

% %% FIXATION SETUP
% 
% % Set up the fixation point, in a try-catch structure to log errors
% try
%     % Prepare the central fixation point based on the window & parameters
%     [fixSize, fixRect, fixCol] = setupFixation(params, winRect);
% 
% catch exception
% 
%     % Log the exception if it has been caught
%     logError(logFile, exception);
% 
% end
% 
% % Save the visual degree-converted fixation size
% in.fixSize = fixSize;
% 
% % Prepare an image rectangle where stimuli will be presented, positioned at
% % the center and based on image size
% % ImageRect = CenterRect([0 0 m m], winRect);

   
%% RUN-SPECIFIC PARAMETERS

% Prompt user to confirm which run to start now
in.runNum = str2double(inputdlg('Start run #:', '', 1, {''}));

% Extract the trials of the run
runTrials = trialList([trialList.run] == in.runNum);

% Based on the run number find the button mapping & instructions
butMap = unique([runTrials.respKey]);
respInst = unique([runTrials.respInst]);

%% INSTRUCTIONS

% Generate the run-specific instructions
displayInstructions(win, params, in, respInst);

% Display them on screen and log it
[VBLTimestamp, ~, ~, ~] = Screen('Flip', win);
% Log this event, recording the time at which the instructions were displayed.
fprintf(logFile, 'FLIP\tInstr\t%d\t%s\t-\t%f\t-\t-\n', in.runNum, string(datetime('now', 'Format', 'yyyy-MM-dd HH:mm:ss.SSS')), VBLTimestamp - in.scriptStart);

% Log the key press confirming participant has read the instructions
conditionFunc = @(x) true; % A placeholder condition function that always returns true.
% switch back to this function eventually  
%LogKeyPress(params, in, logFile, false, true, conditionFunc);
% I'm using this function below due to a problem on my laptop
debugLogKeyPress(params, in, logFile, false, true, conditionFunc, keyboardID);


%% TRIGGER WAIT

% Display a message on screen while waiting for the scanner trigger
DrawFormattedText(win, params.triggerWaitText, 'center', 'center', black);

% Display the message and log it
[VBLTimestamp, ~, ~, ~] = Screen('Flip', win);
% Log the screen flip event, indicating that the experiment is in a trigger-wait state
fprintf(logFile, 'FLIP\tTgrWait\t%d\t%s\t-\t%f\t-\t-\n', in.runNum, string(datetime('now', 'Format', 'yyyy-MM-dd HH:mm:ss.SSS')), VBLTimestamp - in.scriptStart);

% Record the trigger signal
% ** We record the trigger twice because of a bug where MR8 sends 2
% triggers **
conditionFunc = @(x) true; % A condition function that always returns true, used here for simplicity.
% here again, switch back to non-debug function afterwards
% LogKeyPress(params, in, logFile, true, false, conditionFunc); % First call to wait for and log the trigger signal.
% LogKeyPress(params, in, logFile, true, false, conditionFunc); % Second call, if needed, based on your setup.
debugLogKeyPress(params, in, logFile, true, false, conditionFunc, keyboardID); % First call to wait for and log the trigger signal.
debugLogKeyPress(params, in, logFile, true, false, conditionFunc, keyboardID); % Second call, if needed, based on your setup.

%% TRIAL LOOP

% Show an initial fixation display
Screen('FillRect', win, gray); % Fill the screen with gray
displayFixation(win, winRect, in); % Draw the fixation element

% Display the fixation cross and log it
[VBLTimestamp, ~, ~, ~] = Screen('Flip', win); % Flip the screen to display the fixation cross.
% Log this fixation display event, marking the onset of the fixation period in the experiment log file.
fprintf(logFile, 'FLIP\tFix\t%d\t%s\t-\t%f\t-\t-\n', in.runNum, string(datetime('now', 'Format', 'yyyy-MM-dd HH:mm:ss.SSS')), VBLTimestamp - in.scriptStart);




%% FINAL FIXATION

%% SAVE AND CLOSE











