


%% CLEANUP AND SETUP

% Clean up the environment
clc; % Clear the Command Window.
close all; % Close all figures (except those of imtool.)
clear; % Clear all variables from the workspace.

% Initialise psychtoolbox (PTB)
initialisePTB();

% Decide on the debug and PC mode
debug = true; % Debug mode flag. Set to false for actual experiment runs.
fmriPC = false; % Computer mode flag. Set to true whenrunning on the fMRI scanner computer.

%% CHECK AND SET WORKING DIRECTORY
% Prompt the user to confirm if the current directory and PATH settings are correct.
response = input('Did you set the current directory to the fMRI folder (i.e., fMRI_pilot), AND added the "src" and "utils" folders to PATH? (y/n) ', 's');

% Check that the source and utilities paths have been added
checkWD()

% Check the user's response. If 'n', remind the user to set the directory and PATH.
if strcmp(response, 'n')
    disp('Please, set the current directory to the fMRI folder (i.e., fMRI_pilot), AND add the "src" and "utils" folders to PATH (right-click -> add to path).');
    return; % Exit the script if the setup is incorrect.
elseif strcmp(response, 'y')