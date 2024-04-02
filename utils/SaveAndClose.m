function SaveAndClose(params, in, debugMode, varargin)
% SAVEANDCLOSE - Save data and close resources.
%
%    Syntax:
%      SaveAndClose(params, in, varargin)
%
%    Inputs:
%      - parals: Struct containing experiment parameters
%      - in: Struct containing run information.
%      - varargin: Optional additional variables to be saved. These can include:
%           - runTrials: Array storing info about trials and responses.
%           - runImMat: Struct storing info about the images (one image per row).
%           - logFile: File identifier of the log file.
%
%     Description:
%       This function saves relevant variables and files, and closes resources such as
%       the task screen, log file, and input devices. The variables `params` and `in`
%       are required, while the other variables are optional and will be saved if 
%       provided.
%
%   Example:
%       SaveAndClose(params, in, 'runTrials', runTrials, 'runImMat', runImMat, 'logFile', logFile)
%
% Andrea Costantino [16/6/23]

% Parse input arguments
ip = inputParser;
addOptional(ip, 'runTrials', [], @(x) isnumeric(x) || iscell(x));
addOptional(ip, 'runImMat', [], @(x) isstruct(x) || isempty(x) || iscell(x));
addOptional(ip, 'logFile', [], @isnumeric);
parse(ip, varargin{:});

runTrials = ip.Results.runTrials;
runImMat = ip.Results.imList;

% Show the mouse cursor again
ShowCursor;

% Close all open Psychtoolbox screens
Screen('CloseAll');

% Enable character listening again
ListenChar(0);

if debugMode ~= 1
    % Close the log file
    if ~isempty(ip.Results.logFile)
        fclose(ip.Results.logFile);
    end
    
    % Generate a unique identifier for the data and save data
    runInfo = [sprintf('%02d', in.subNum) '_' num2str(in.runNum)];
    dataName = fullfile(in.resDir, [dateTimeStr '_' runInfo '_' in.taskName '.mat']);
    save(dataName, 'params', 'in', 'runTrials', 'runImMat', '-v7.3');
end

end
