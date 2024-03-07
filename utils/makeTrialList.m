function trialList = makeTrialList(params)
% MAKESTIMLIST Creates a stimulus list based on the parameters provided.
%   This function fetches files from the stimulus directory specified in
%   the parameters and generates a stimulus list for the experiment.

% Fetch the files from the stimulus directory
files = dir(params.stimDir);

% Count the number of files
numStim = length(files);

% First possibility: a file with a list of stimuli has been provided
% Check if params.stimListFile exists
if isfield(params, 'stimListFile') && exist(params.stimListFile, 'file') == 2
    % Read the stimulus list file
    fid = fopen(params.stimListFile, 'r');
    if fid == -1
        error(['Could not open stimulus list file: ', params.stimListFile]);
    end
    
    % Read lines from the file
    stimList = textscan(fid, '%s %s');
    
    % Close the file
    fclose(fid);

    % Make a design list based on the input stim list & number of runs
    % Calculate how many trials per run
    trialsPerRun = floor(length(stim_list) / params.numRuns);
    % Make a list of runs corresponding to the trials
    runColumn = repelem(1:params.numRuns, trialsPerRun)';
    % Create the output trial list
    trialList = struct();
    % Assign values to each field
    for i = 1:stimList
        trialList(i).run = runColumn(i);
        trialList(i).filename = stimList(i);
    end


% Second possibility: no list has been provided
else
    % Fetch the desired total number of trials
    totalNumTrials = params.numRuns * params.trialsPerRun;

    % Check if the length of stim_list matches total_num_trials
    if numStim ~= totalNumTrials
        error('Number of trials in stimListFile does not match the input total number of trials.');
    end

    % Check the ratio between total num trials and stim list
    ratio = totalNumTrials / numStim;
    % If necessary, duplicate the elements from the stimulus list
    duplicatedFiles = files
    if ratio > 1
        for i = 2:ratio
            duplicatedFiles = [files; files];
        end
    end

    % Make a list of runs corresponding to the trials
    runColumn = repelem(1:params.numRuns, params.trialsPerRun)';
    % Create the output trial list
    trialList = struct();
    % Assign values to each field
    for i = 1:totalNumTrials
        trialList(i).run = runColumn(i);
        trialList(i).filename = fullfile(duplicatedFiles(i).folder, duplicatedFiles(i).name);
    end

end

end
