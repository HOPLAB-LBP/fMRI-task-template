function checkWD()
% CHECKWD Checks and adds default directories to the MATLAB path.
%   This function checks if default directories for utility functions and
%   source files exist in the current working directory. If they do not
%   exist, the user is prompted to provide the paths. The function then
%   adds these directories to the MATLAB path.

% Declare default directory paths for the utilities and source
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

% Add both directories to the MATLAB path
addpath({default_utils_dir, default_src_dir});

disp('Directories have been added to the MATLAB path.');

end