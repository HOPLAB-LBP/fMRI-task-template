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
debugMode = false; % debugMode mode flag. Set to false for actual experiment runs.
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

% Store some 

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
fprintf(logFile, 'EVENT_TYPE\tEVENT_NAME\tDATETIME\tEXP_ONSET\tACTUAL_ONSET\tDELTA\tEVENT_ID\n');

%% SCREEN SETUP

% Set up the PTB screen, in a try-catch structure to log errors
try
    % Configure the PTB graphics window based on parameters and debug mode
    [win, winRect, VBLTimestamp] = setupScreen(params, debugMode);
    
    % Store the screen setup time stamp
    in.VBLTimestamp = VBLTimestamp;
    
    % Log the experiment start event with its timestamp
    fprintf(logFile, 'START\t-\t%s\t-\t%f\t-\t-\n', string(datetime('now', 'Format', 'yyyy-MM-dd HH:mm:ss.SSS')), VBLTimestamp-in.scriptStart);
    
    % Configure the screen colours
    [white, gray, black] = configScreenCol(params);
    
    % is this useful?
    c = 'center';
    % % Calculate the number of pixels per degree of visual angle to support visual stimuli sizing.
    PPD = convertVisualUnits(1, 'deg', 'px'); % Convert 1 degree of visual angle to pixels.
    in.PPD = PPD; % Store the pixels per degree value for use in stimuli sizing.

catch exception

    % Log the exception if it has been caught
    logError(logFile, exception);

end



%% FIXATION SETUP

% This section prepares the central fixation point.
        
% Convert the fixation size from degrees of visual angle to pixels. 
% This adjustment ensures that the fixation's size is appropriate for the screen's resolution and viewing distance.
FixSize = round(convertVisualUnits(p.fixSize, 'deg', 'px')); 

% Initialize an array to store rectangle coordinates for drawing the fixation point.
% For each dimension specified in p.fixSize, calculate the rectangle's coordinates.
% This loop allows for the creation of a composite fixation symbol, potentially consisting of multiple elements.
for i = 1:length(p.fixSize)
    % Calculate the rectangle for the fixation component.
    % The CenterRect function creates a rectangle of the specified size, centered within the window.
    % Dividing FixSize by 2 ensures the dimensions are correctly centered around the fixation point.
    FixRect(:,i) = CenterRect([0 0 FixSize(i)/2 FixSize(i)/2], winRect); 
end

% Define the colors for the fixation point. This matrix specifies colors for each element of the fixation.
% The sequence [0 0 0; 255 255 255; 0 0 0]' defines a black-white-black pattern when multiple elements are drawn.
FixCol = [0 0 0;  255 255 255; 0 0 0]';

% Set up the image rectangle, defining the area where stimuli will be presented.
% The CenterRect function is used again to ensure that the stimulus is centered on the screen.
% The dimensions [0 0 m m] create a square area based on the size of the first image loaded (m by m pixels).
ImageRect = CenterRect([0 0 m m], winRect);
 
%% BEGIN THE EXPERIMENT

% Declare a default run number to start from
in.runNum = 1;

% Start going over the trial list, until we reach the end of it
while true
    %% RUN-SPECIFIC PARAMETERS
    % Prompt user to confirm which run to start now
    currentRun = {num2str(in.runNum)}; % declare a default option (next run)
    in.runNum = str2double(inputdlg('Start run #:', '', 1, currentRun));

    % Extract the trials of the run
    runTrials = trialList([trialList.run] == in.runNum);
    
    % Based on the run number find the button mapping
    butMap = unique([runTrials.respKey]);

    %% INSTRUCTIONS

    %% TRIGGER WAIT

    %% TRIAL LOOP

    %% END OF THE TRIAL LOOP

    % Interupt the while loop when it's done
    % If the end is reached, interrupt the while loop
    if in.runNum == max([trialList.run]);
        break
    end

    % Continue onto the next run: update the run number
    in.runNum = in.runNum + 1;

end



%% FINAL FIXATION

%% SAVE AND CLOSE











