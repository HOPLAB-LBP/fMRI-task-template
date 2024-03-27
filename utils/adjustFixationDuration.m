function adjustedFixDur = adjustFixationDuration(runTrials, trialNum, params)
% ADJUSTFIXATIONDURATION Adjusts fixation duration based on timing deviations.
%
%   adjustedFixDur = ADJUSTFIXATIONDURATION(trialList, p) calculates the
%   adjusted fixation duration for a trial based on the timing of the trial
%   relative to its scheduled time. It ensures that stimulus presentation
%   aligns closely with planned timings.
%
%   Inputs:
%     - runTrials: A structure containing trial information for the ongoing 
%           run, with rows representing trials and fields containing data 
%           such as actual start time (stimOnset) and expected start time
%           (idealStimOnset).
%     - params: A structure containing parameters, including 'fixDur', 
%           which is the initial fixation duration.
%
%   Output:
%     - adjustedFixDur: The adjusted fixation duration for the trial.
%
%   Example:
%     % Define runTrials and params
%     runTrials = [1 2 3 4 5; 2 2 2 6 7]; % Example trial list
%     params.fixDur = 1.5; % Initial fixation duration
%
%     % Calculate adjusted fixation duration
%     adjustedFixDur = adjustFixationDuration(runTrials, i, params);

% Calculate the time difference between the actual and expected start times.
timeDif = abs(runTrials(trialNum).stimOnset - runTrials(trialNum).idealStimOnset); 

% If stimulus onset is larger than expected i.e. we're running "behind"
if runTrials(trialNum).stimOnset > runTrials(trialNum).idealStimOnset
    % Solution: duration of the stimulus = fixation duration - time difference
    adjustedFixDur = params.fixDur - timeDif;

% If stimulus onset is smaller than expected i.e. we're running "ahead"
elseif runTrials(trialNum).stimOnset < runTrials(trialNum).idealStimOnset
    % Solution: duration of the stimulus = fixation duration + time difference
    adjustedFixDur = params.fixDur + timeDif;
end