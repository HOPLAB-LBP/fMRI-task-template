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
debugModeMode = false; % debugMode mode flag. Set to false for actual experiment runs.
fmriMode = true; % Computer mode flag. Set to true whenrunning on the fMRI scanner computer.

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

% Initialise psychtoolbox (PTB)
initializePTB();

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
 
%% BEGIN THE EXPERIMENT

% Declare a default run number to start from
in.runNum = 1;

% Start going over the trial list, until we reach the end of it
while true

    % Prompt user to confirm which run to start now
    currentRun = {num2str(in.runNum)}; % declare a default option (next run)
    in.runNum = str2double(inputdlg('Start run #:', '', 1, currentRun));

    % Extract the trials of the run
    runTrials = trialList([trialList.run] == in.runNum);
    
    % Based on the run number find the button mapping
    butMap = unique([runTrials.respKey]);
    

    %% START LOGGING
    
    % Determine the logging destination based on the debugMode mode
    if in.debugMode == true
        % Log in the command window ('1')
        logFile = 1;
    else
        % Create a new run- and subject-dependent log file
        logFile = createLogFile(params, in);
    end
    
    % Write the header row to the log file, including variable names
    fprintf(logFile, 'EVENT_TYPE\tEVENT_NAME\tDATETIME\tEXP_ONSET\tACTUAL_ONSET\tDELTA\tEVENT_ID\n');

    %% SCREEN SETUP
    
    % Start with a command to check if the screen works or something (try …
    % except)

    % Configure the PTB graphics window based on the parameters and debug mode
    [win, winRect] = setupScreen(params, debugMode);
    
    % Perform an initial screen flip to synchronize the start of the experiment
    [VBLTimestamp, ~, ~, ~] = Screen('Flip', win);

    % Record the timestamp of the experiment start for timing calculations
    in.scriptStart = VBLTimestamp;

    % Log the experiment start event with its timestamp
    fprintf(logFile, 'START\t-\t%s\t-\t%f\t-\t-\n', string(datetime('now', 'Format', 'yyyy-MM-dd HH:mm:ss.SSS')), VBLTimestamp-in.scriptStart);
    
    % Configure the text and color parameters for stimulus presentation.
    c = 'center'; % Define a shorthand for text alignment.
    Screen('TextSize', win, 30); % Set the font size for text displayed onscreen.
    Screen('TextFont', win, 'Helvetica'); % Set the font type to Helvetica for readability.
    black = BlackIndex(screen); % Obtain the CLUT index for black.
    white = WhiteIndex(screen); % Obtain the CLUT index for white.
    gray = round(white / 2); % Calculate a gray value as the midpoint between black and white.
    
    % Calculate the number of pixels per degree of visual angle to support visual stimuli sizing.
    PPD = convertVisualUnits(1, 'deg', 'px'); % Convert 1 degree of visual angle to pixels.
    in.PPD = PPD; % Store the pixels per degree value for use in stimuli sizing.

        %%



    % Actually run the trials here




    % Interupt the while loop when it's done
    % If the end is reached, interrupt the while loop
    if in.runNum == max([trialList.run]);
        break
    end

    % Continue onto the next run: update the run number
    in.runNum = in.runNum + 1;

end











