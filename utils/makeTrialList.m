function trialList = makeTrialList(params, in)
% MAKETRIALLIST - Generate a list of trials based on provided parameters and input data.
%
%   trialList = MAKETRIALLIST(params, in) generates a list of trials using
%   parameters stored in the 'params' structure and input data stored in
%   the 'in' structure. It reads a stimulus list file, handles various
%   trial list configurations (exact, fewer, or more stimuli than needed),
%   ensures balanced repetition or selection, randomizes trials as required,
%   adds run numbers, calculates ideal stimulus onset times, and fills the
%   trial list structure with relevant information.
%   
%   It also keeps any extra variable contained in the .tsv file containing
%   the list of trials that you provide with 'params.stimListFile', and 
%   saves it with its original name in the output.
%
%   Input:
%       - params: A structure containing parameters required to generate
%                 the trial list. It must include fields: 'stimListFile',
%                 'numRuns', 'prePost', 'trialDur', 'numRepetitions'.
%                 Optional field 'stimRandomization' ('run', 'all', or omit for none).
%       - in: A structure containing input data, such as subject number.
%
%   Output:
%       - trialList: A structure array containing information about each trial,
%                    including trial number, run number, button mapping,
%                    subject number, ideal stimulus onset time, and placeholders
%                    for subject response and actual stimulus onset.
%
%   Trial List Generation Logic:
%       The function handles three scenarios:
%       1. EXACT: stimuli * numRepetitions == numRuns * trialsPerRun
%          -> Simple replication and division
%       2. FEWER: stimuli * numRepetitions < numRuns * trialsPerRun
%          -> Balanced repetition: all stimuli shown N times, some N+1
%       3. MORE: stimuli * numRepetitions > numRuns * trialsPerRun
%          -> Balanced selection across runs to prevent overrepresentation
%
%   Example:
%       params.stimListFile = 'stimuli.tsv';
%       params.numRuns = 4;
%       params.prePost = 2;
%       params.trialDur = 4;
%       params.numRepetitions = 2;
%       params.stimRandomization = 'run';
%       in.subNum = 1;
%       trialList = makeTrialList(params, in);
% 
%   Author
%   Tim Maniquet [7/3/24]
%   Updated for robustness and balanced trial generation [2025]

% Check if the required fields are present in the params structure
requiredFields = {'stimListFile', 'numRepetitions', 'numRuns', 'prePost', 'trialDur'};
missingFields = setdiff(requiredFields, fieldnames(params));
if ~isempty(missingFields)
    error('makeTrialList:paramsMissing', 'Required field(s) %s missing in the params structure.', strjoin(missingFields, ', '));
end

% Validate stimRandomization parameter if it exists
if isfield(params, 'stimRandomization')
    validRandomizations = {'run', 'all'};
    if ~ismember(params.stimRandomization, validRandomizations)
        error('makeTrialList:invalidRandomization', ...
            'stimRandomization must be ''run'' or ''all''. Got: ''%s''', ...
            params.stimRandomization);
    end
end


% Fetch the stimulus list file and read it
try
    % Read the TSV file
    stimListTable = readtable(params.stimListFile, 'Delimiter', '\t', 'FileType', 'text');
    fprintf('makeTrialList: Successfully read stimulus list from %s\n', params.stimListFile);
    fprintf('makeTrialList: Found %d stimuli with %d columns\n', height(stimListTable), width(stimListTable));
catch exception
    % Display an error message and rethrow
    error('makeTrialList:fileReadError', 'Error reading stimuli list from %s: %s', ...
        params.stimListFile, exception.message);
end

% Validate that the stimuli column exists
if ~ismember('stimuli', stimListTable.Properties.VariableNames)
    error('makeTrialList:missingColumn', ...
        'The stimulus list file must contain a column named ''stimuli''. Found columns: %s', ...
        strjoin(stimListTable.Properties.VariableNames, ', '));
end


% Check if run column is pre-defined in the input file
hasPreDefinedRuns = ismember('run', stimListTable.Properties.VariableNames);

if hasPreDefinedRuns
    % Use pre-defined runs from the input file
    fprintf('makeTrialList: Using pre-defined run assignments from input file\n');
    
    % Apply numRepetitions to the entire table
    stimList = repmat(stimListTable, params.numRepetitions, 1);
    
    % Calculate trials per run from the data
    runNumbers = unique(stimList.run);
    trialsPerRun = zeros(1, length(runNumbers));
    for i = 1:length(runNumbers)
        trialsPerRun(i) = sum(stimList.run == runNumbers(i));
    end
    
    % Validate that all runs have the same number of trials
    if length(unique(trialsPerRun)) > 1
        error('makeTrialList:unevenRuns', ...
            'Pre-defined runs must have equal number of trials. Found: %s', ...
            mat2str(trialsPerRun));
    end
    
    trialsPerRun = trialsPerRun(1);
    fprintf('makeTrialList: %d trials per run across %d runs (total: %d trials)\n', ...
        trialsPerRun, params.numRuns, height(stimList));
    
else
    % Calculate how many trials we need in total
    totalTrialsNeeded = params.numRuns * floor(height(stimListTable) * params.numRepetitions / params.numRuns);
    trialsPerRun = totalTrialsNeeded / params.numRuns;
    
    fprintf('makeTrialList: Need %d total trials (%d runs × %d trials/run)\n', ...
        totalTrialsNeeded, params.numRuns, trialsPerRun);
    
    % Determine the scenario and generate trial list accordingly
    numUniqueStimuli = height(stimListTable);
    totalAvailable = numUniqueStimuli * params.numRepetitions;
    
    fprintf('makeTrialList: %d unique stimuli × %d repetitions = %d available trials\n', ...
        numUniqueStimuli, params.numRepetitions, totalAvailable);
    
    if totalAvailable == totalTrialsNeeded
        % SCENARIO 1: EXACT MATCH - Simple replication
        fprintf('makeTrialList: EXACT MATCH - Simple replication\n');
        stimList = repmat(stimListTable, params.numRepetitions, 1);
        
    elseif totalAvailable < totalTrialsNeeded
        % SCENARIO 2: FEWER STIMULI - Need balanced repetition
        fprintf('makeTrialList: FEWER STIMULI - Applying balanced repetition\n');
        
        % Calculate how many times each stimulus should appear (base + extra)
        baseRepetitions = floor(totalTrialsNeeded / numUniqueStimuli);
        extraRepetitions = mod(totalTrialsNeeded, numUniqueStimuli);
        
        fprintf('makeTrialList: Each stimulus will appear %d times, with %d stimuli appearing %d times\n', ...
            baseRepetitions, extraRepetitions, baseRepetitions + 1);
        
        % Create base repetitions for all stimuli
        stimList = repmat(stimListTable, baseRepetitions, 1);
        
        % Add extra repetitions balanced across stimuli
        if extraRepetitions > 0
            % Randomly select which stimuli get the extra repetition
            extraIndices = randperm(numUniqueStimuli, extraRepetitions);
            extraStimuli = stimListTable(extraIndices, :);
            stimList = [stimList; extraStimuli];
        end
        
    else
        % SCENARIO 3: MORE STIMULI - Need balanced selection
        fprintf('makeTrialList: MORE STIMULI - Applying balanced selection across runs\n');
        
        % For balanced selection across runs, we select a subset for each run
        % ensuring each stimulus is selected approximately equally often
        
        stimList = table();
        stimuliPerRun = trialsPerRun;
        
        % Calculate how many times each stimulus should be selected overall
        timesEachStimulusUsed = floor(totalTrialsNeeded / numUniqueStimuli);
        extraSelections = mod(totalTrialsNeeded, numUniqueStimuli);
        
        fprintf('makeTrialList: Selecting %d stimuli per run\n', stimuliPerRun);
        fprintf('makeTrialList: Target: each stimulus used %d times, %d stimuli used %d times\n', ...
            timesEachStimulusUsed, extraSelections, timesEachStimulusUsed + 1);
        
        % Create a usage counter for each stimulus
        usageCount = zeros(numUniqueStimuli, 1);
        targetCount = repmat(timesEachStimulusUsed, numUniqueStimuli, 1);
        
        % Some stimuli should be used one extra time
        if extraSelections > 0
            extraIndices = randperm(numUniqueStimuli, extraSelections);
            targetCount(extraIndices) = targetCount(extraIndices) + 1;
        end
        
        % For each run, select stimuli that haven't reached their target yet
        for runIdx = 1:params.numRuns
            % Find stimuli that haven't reached their target
            availableStimuli = find(usageCount < targetCount);
            
            % Randomly select from available stimuli
            if length(availableStimuli) < stimuliPerRun
                error('makeTrialList:selectionError', ...
                    'Cannot select enough stimuli for run %d. Available: %d, Need: %d', ...
                    runIdx, length(availableStimuli), stimuliPerRun);
            end
            
            selectedIndices = availableStimuli(randperm(length(availableStimuli), stimuliPerRun));
            
            % Add selected stimuli to the list
            runStimuli = stimListTable(selectedIndices, :);
            stimList = [stimList; runStimuli];
            
            % Update usage count
            usageCount(selectedIndices) = usageCount(selectedIndices) + 1;
        end
        
        fprintf('makeTrialList: Selection complete. Usage range: %d to %d times per stimulus\n', ...
            min(usageCount), max(usageCount));
    end
    
    % Add run numbers to the stimulus list
    runList = repelem(1:params.numRuns, trialsPerRun)';
    runTable = array2table(runList, 'VariableNames', {'run'});
    stimList = [stimList, runTable];
    
    fprintf('makeTrialList: Run assignments added to trial list\n');
end


% Randomize trials if required, respecting run boundaries
if isfield(params, 'stimRandomization')
    if strcmp(params.stimRandomization, 'run')
        % Randomize within each run
        fprintf('makeTrialList: Randomizing trials within each run\n');
        
        % Create a copy for randomization
        stimListRandomized = stimList;
        
        for runIdx = 1:params.numRuns
            % Find the indices of trials for the current run
            runIndices = find(stimList.run == runIdx);
            
            % Create a random permutation of these indices
            randomOrder = randperm(length(runIndices));
            
            % Apply the randomization to this run's trials
            stimListRandomized(runIndices, :) = stimList(runIndices(randomOrder), :);
        end
        
        stimList = stimListRandomized;
        fprintf('makeTrialList: Randomization complete (within-run)\n');
        
    elseif strcmp(params.stimRandomization, 'all')
        % Randomize across all runs (respecting total run structure)
        fprintf('makeTrialList: Randomizing trials across all runs\n');
        
        % Create a random permutation of all trials
        randIdx = randperm(height(stimList));
        stimList = stimList(randIdx, :);
        
        % Re-assign run numbers to maintain equal run lengths
        % (the randomization shuffles which stimuli go to which run)
        stimList.run = repelem(1:params.numRuns, trialsPerRun)';
        
        fprintf('makeTrialList: Randomization complete (across-run)\n');
    end
else
    fprintf('makeTrialList: No randomization applied (keeping original order)\n');
end


% Extract run list (now guaranteed to exist)
runList = stimList.run;

% Calculate the ideal stimulus onset times for one run
stimOnsetRun = params.prePost:params.trialDur: ...
    (trialsPerRun*params.trialDur)+(params.prePost-params.trialDur);

% Extend to the complete trial list
stimOnsetList = [];
for runIdx = 1:params.numRuns
    stimOnsetList = [stimOnsetList stimOnsetRun];
end

fprintf('makeTrialList: Calculated ideal stimulus onset times\n');

% Initiate the trial list as a structure and fill it with information
trialList = table2struct(stimList);

% Add relevant columns to the trial list structure
for i = 1:numel(trialList)
    % Declare a trial number
    trialList(i).trialNb = i;
    % Declare a run number
    trialList(i).run = runList(i);
    % Declare a button mapping based on subject and run number
    trialList(i).butMap = determineButtonMapping(params, in.subNum, trialList(i).run).mapNumber;
    trialList(i).respKey1 = determineButtonMapping(params, in.subNum, trialList(i).run).respKey1;
    trialList(i).respKey2 = determineButtonMapping(params, in.subNum, trialList(i).run).respKey2;
    trialList(i).respInst1 = determineButtonMapping(params, in.subNum, trialList(i).run).respInst1;
    trialList(i).respInst2 = determineButtonMapping(params, in.subNum, trialList(i).run).respInst2;
    % Declare a subject number
    trialList(i).subNum = in.subNum;
    % Declare the ideal stimulus onset times
    trialList(i).idealStimOnset = stimOnsetList(i);
    % Declare a placeholder for subject response
    trialList(i).response = NaN;
    % Declare a placeholder for actual stimulus onset
    trialList(i).stimOnset= NaN;
end

% Final summary
fprintf('makeTrialList: Trial list generation complete\n');
fprintf('makeTrialList: Total trials: %d\n', length(trialList));
fprintf('makeTrialList: Trials per run: %d\n', trialsPerRun);
fprintf('makeTrialList: Number of runs: %d\n', params.numRuns);

% Calculate and report unique stimuli usage
uniqueStimNames = unique({trialList.stimuli});
stimCounts = zeros(1, length(uniqueStimNames));
for i = 1:length(uniqueStimNames)
    stimCounts(i) = sum(strcmp({trialList.stimuli}, uniqueStimNames{i}));
end
fprintf('makeTrialList: Unique stimuli: %d\n', length(uniqueStimNames));
fprintf('makeTrialList: Stimulus usage: min=%d, max=%d, mean=%.2f\n', ...
    min(stimCounts), max(stimCounts), mean(stimCounts));

end
