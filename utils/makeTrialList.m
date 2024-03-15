function trialList = makeTrialList(params, in)
% MAKETRIALLIST Creates a stimulus list based on the parameters provided.
%   This function fetches image filenames from the external file
%   specified in the parameters, and reads it line by line to make
%   a list of trials, accompanied by run numbers according to the
%   run number of the parameters.
%
%   Input:
%       - params: A struct containing parameters including:
%           * stimDir: The directory containing stimulus files.
%           * stimListFile: The file containing a list of stimuli.
%           * numRuns: The number of runs.
%
%   Output:
%       - trialList: A struct array containing the list of trials with
%         run numbers and filenames.

% Fetch the files from the stimulus directory
files = dir(params.stimDir);

% Fetch the stimulus list file and read it
fid = fopen(params.stimListFile, 'r');

% Give an error if the file can't be read
if fid == -1
    error(['Could not open stimulus list file: ', params.stimListFile]);
end

% Read the data from the lines ofthe file
stimListData = textscan(fid, '%s %s');

% Create an empty list to hold onto the file values
stimList = cell(1, length(stimListData{1}));

% Add the elements of the lines data to the list as strings
for i = 1:numel(stimList)
    % Remove potential quotation marks
    stimListData{1}{i} = strrep(stimListData{1}{i}, '"', '');
    stimListData{1}{i}= strrep(stimListData{1}{i}, '''', '');
    % Add the filename to the list
    stimList{i} = stimListData{1}{i};
end 

% Close the file
fclose(fid);

% If we have different numbers of files and trials, give a warning
if length(files) > length(stimList)
   warning('You have %d trials and %d files. Not all files will be used.', length(stimList), length(files));
elseif length(files) < length(stimList)
    warning('You have %d trials and %d files. Some files will be used several times.', ...
        length(stimList), length(files));
end

% Problems would arise if the number of trials defined in the external
% file is not divisible by the number of runs
if ~ mod(length(stimList), params.numRuns) == 0
    error(['Your list of %d trials cannot be divided into %d runs of equal length.', ...
        length(stimList), params.numRuns]);
end

% Make a design list based on the input stim list & number of runs
% Calculate how many trials per run
trialsPerRun = floor(length(stimList) / params.numRuns);
% Make a list of runs corresponding to the trials
runColumn = repelem(1:params.numRuns, trialsPerRun)';
% Create the output trial list
trialList = struct();
% Assign values to each field
for i = 1:length(stimList)
    % Write the run number
    trialList(i).run = runColumn(i);
    % Extract the filename string from the list
    stimFileCell = stimList(i);
    stimFileStr = stimFileCell{1};
    % Write the image file path
    trialList(i).filename = stimFileStr;
end

% Calculate the ideal stimulus onset times for one run
stimOnsetRun= params.prePost:params.trialDur: ...
    (trialsPerRun*params.trialDur)+(params.prePost-params.trialDur);
% Make a list to extend to the complete trial list
stimOnsetList = stimOnsetRun;
for i = 2:params.numRuns
    stimOnsetList = [stimOnsetList stimOnsetRun];
end

% Add relevant columns to the trial list structure
for i = 1:numel(trialList)
    % Declare a trial number
    trialList(i).trialNb = i;
    % Declare a button mapping based on subject and run number
    trialList(i).butMap = determineButtonMapping(params, in.subNum, trialList(i).run).mapNumber;
    trialList(i).respKey = determineButtonMapping(params, in.subNum, trialList(i).run).respKey;
    trialList(i).respInst = determineButtonMapping(params, in.subNum, trialList(i).run).respInst;
    % Declare a subject number
    trialList(i).subNum = in.subNum;
    % Declare the ideal stimulus onset times
    trialList(i).idealStimOnset = stimOnsetList(i);
    % Declare a placeholder for subject response
    trialList(i).response = NaN;
    % Declare a placeholder for actual stimulus onset
    trialList(i).stimOnset= NaN;
end

end
