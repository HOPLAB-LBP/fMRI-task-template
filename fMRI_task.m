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

% Decide on the debug and PC mode
debug = false; % Debug mode flag. Set to false for actual experiment runs.
fmriPC = false; % Computer mode flag. Set to true whenrunning on the fMRI scanner computer.

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
addpath({default_utils_dir, default_src_dir});
disp('Directories have been added to the MATLAB path.');

%% IMPORT EXTERNAL PARAMETERS & INITIALISE PTB

% Use the parse parameter function to import all parameters from file
params = parseParameterFile('parameters.txt');

% Initialise psychtoolbox (PTB)
initialisePTB();

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

%% SUBJECT NUMBER AND RUN NUMBER

% Declare subject number and decide on the run to start from
if debug == true
    answer = {'99','9'}; % Default values for subject and run numbers in debug mode
    % in.butMap = 1; % Default button mapping in debug mode
else
    % Else if in actual experiment mode
    prompt = {'subject number','run number'};
    def = {'', ''};
    answer = inputdlg(prompt,'',1,def);
end

% Store subject number and run number
in.subNum = str2double(answer{1});
in.runNum = str2double(answer{2});

% Save a timestamp in the input parameters
in.timestamp = string(datetime('now', 'Format', 'yyyy-MM-dd_HHmmss'));

%% SETUP RESULTS DIRECTORY

% Prepares a subject-specific results directory to store outputs

% Construct the path to the results directory for the current subject.
% The directory name includes the subject identifier (e.g., 'sub-1') to separate data by subject.
resDir = fullfile(dr, 'data', ['sub-' answer{1}]);
in.resDir = resDir; % Store the constructed path in the 'in' structure for later use.

% Check if the results directory exists & if we're not in debug mode
if exist(resDir, 'dir') == 0 && debug == false
    mkdir(resDir);
end

%% TRIALS LIST

% Create a list of trials based on the input parameters
trialList = makeTrialList(params);

% Make a file name with subject number and time stamp
trialListFilename = sprintf('./trialList_subj%d_%s.tsv', in.subNum, in.timestamp);
trialListDir = fullfile(resDir, trialListFilename);

% Save the list as a tsv file
tsvTable = struct2table(trialList);
writetable(tsvTable, trialListDir, 'FileType','text', ...
    'Delimiter', '\t');

%% BEGIN THE EXPERIMENT

% Ensure that the screen gets closed when the script terminates.
cleanObj = onCleanup(@()sca);



% BUTTON MAPPING

% at the start of each run, determine a button mapping
% based on the input parameters and the global parameters
% we could set a default butmap if debug is set to true

% Determine button mapping based on parameters, subject & run number
butMap = determineButtonMapping(in, params);





% where we'll resize the stimuli
% considering 'im' is the input stimulus:
resized_im = resizeStim(im, params.resizeMode, params.resizeStimVarargin{:})





















