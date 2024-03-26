function logFile = createLogFile(params, in)
% CREATELOGFILE - Create a log file for recording experiment data.
%
%   logFile = CREATELOGFILE(params, in) creates a log file to record 
%   all experiment data, trial by trial. The log file will be named and
%   saved based on values from the user input (in) and global parameters
%   (params).
%   The output log file is taken as input by the logOutput function,
%   which will write logging output in it, line by line, if not in 
%   debug mode.
%
%   Input arguments:
%   - params: A structure containing parameters for the experiment,
%       including:
%     * taskName: the short name given to the task by the experimenter.
%   - in: A structure containing input information, including:
%     * subNum: Subject number for the experiment.
%     * runNum: Run number for the experiment.
%     * resDir: Subject-specific directory path where the log file 
%       will be saved.
%
%   Output argument:
%   - logFile: File identifier for the created log file.

% Check if the required fields are present in the params structure
requiredFields = {'taskName'};
missingFields = setdiff(requiredFields, fieldnames(params));
if ~isempty(missingFields)
    error('createLogFile:paramsMissing', 'Required field(s) %s missing in the params structure.', strjoin(missingFields, ', '));
end


% Create a time stamp
currentDateTime = string(datetime('now', 'Format', 'yyyyMMddHHmmss'));

% Construct a log file name using the time stamp, runID, and task name
logFileName = strcat(currentDateTime, '_log_', num2str(in.subNum), '_', params.taskName, '.tsv');

% Create a path for the log file in the results folder
logFilePathName = fullfile(in.resDir, logFileName);

% Initiate the log file by creating it in write mode
logFile = fopen(logFilePathName, 'a');

end
