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

% Decide on the debug and PC mode
debug = false; % Debug mode flag. Set to false for actual experiment runs.
fmriPC = true; % Computer mode flag. Set to true whenrunning on the fMRI scanner computer.

%% CHECK AND SET WORKING DIRECTORY

% Declare default directories for the source and utilities
default_utils_dir = './utils';
default_src_dir = './src';

% Check if the default utility directory exists
while ~exist(default_utils_dir, 'dir')
    disp(['Utility directory "', default_utils_dir, '" does not exist.']);
    % Prompt the user to input the utility directory
    utils_dir = input('Please provide the path to the utility directory: ', 's');
    default_utils_dir = utils_dir;
end

% Check if the default source directory exists
while ~exist(default_src_dir, 'dir')
    disp(['Source directory "', default_src_dir, '" does not exist.']);
    % Prompt the user to input the source directory
    src_dir = input('Please provide the path to the source directory: ', 's');
    default_src_dir = src_dir;
end

% Add both directories to the MATLAB path once we're sure they exist
addpath(default_src_dir);
addpath(default_utils_dir); 
disp('Directories have been added to the MATLAB path.');

%% IMPORT EXTERNAL PARAMETERS & INITIALISE PTB

% Use the parse parameter function to import all parameters from file
params = parseParameterFile('parameters.txt');

% Initialise psychtoolbox (PTB)
initializePTB();

%% DEFINE MODE-DEPENDENT PARAMETERS

% If fmri mode is selected
if fmriPC == true
    params.scrDist = params.scrDistMRI; % screen distance
    params.scrWidth = params.scrWidthMRI; % screen width
    params.respKey = params.respKeyMRI; % response keys
    params.triggerKey = params.triggerKeyMRI; % trigger key
elseif fmriPC == false
    params.scrDist = params.scrDistPC; % screen distance
    params.scrWidth = params.scrWidthPC; % screen width
    params.respKey = kbName(params.respKeyPC); % response keys
    params.triggerKey = kbName(params.triggerKeyPC); % trigger key
end

%% USER INPUT: SUBJECT NUMBER

% Declare subject number and decide on the run to start from
if debug == true
    answer = {'99'}; % Default values for subject number in debug mode
    % in.butMap = 1; % Default button mapping in debug mode
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

% Check if the results directory exists & if we're not in debug mode
if exist(resDir, 'dir') == 0 && debug == false
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
    
    % Record all events in a run-specific log file.
    
    % Construct a unique identifier (runID)
    runID = strcat(num2str(in.subNum), '-', num2str(in.runNum), '-', num2str(butMap(1)), '_', num2str(butMap(2)));
    
    % Capture the current date and time to include in the log file name, providing
    % a timestamp that helps in organizing and identifying log files chronologically.
    current_datetime = string(datetime('now', 'Format', 'yyyyMMddHHmmss'));
    
    % Construct the log file name using the current date and time, the unique runID,
    % and the task name. The file is saved with a '.tsv' extension, indicating that
    % it contains tab-separated values, a format that is easy to read and process.
    logFileName = strcat(current_datetime, '_log_', runID, '_', in.taskName, '.tsv');
    
    % Determine the full path for the log file, ensuring it is stored within the
    % designated results directory for the current subject.
    logFilePathName = fullfile(in.resDir, logFileName);
    
    % Open the log file for writing. If in debug mode, output to the MATLAB command
    % window (denoted by logFile = 1) to avoid creating unnecessary files. Otherwise,
    % open the actual log file for appending data ('a' mode), creating it if it doesn't exist.
    if in.debug == true
        logFile = 1; % Direct output to MATLAB command window in debug mode.
    else
        logFile = fopen(logFilePathName, 'a'); % Open or create log file for writing in non-debug mode.
    end
    
    % Write the header row to the log file. This includes names for each column,
    % defining the types of data that will be logged: event type, event name,
    % datetime of the event, expected onset time, actual onset time, the difference
    % between expected and actual onset times (delta), and an event identifier.
    % The '\t' represents a tab character, used to separate the values in the TSV file.
    fprintf(logFile, 'EVENT_TYPE\tEVENT_NAME\tDATETIME\tEXP_ONSET\tACTUAL_ONSET\tDELTA\tEVENT_ID\n');



    % Actually run the trials here

    % If the end is reached, interrupt the while loop
    if in.runNum == max([trialList.run]);
        break
    end

    % Continue onto the next run: update the run number
    in.runNum = in.runNum + 1;

end











