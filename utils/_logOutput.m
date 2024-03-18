function [outputArg1] = logOutput(logFile,inputArg2)


%% Evaluate logging mode

% If in debug mode, don't save an output file, just print the logging
% in the command window
if debug == true
    logFile = 1; % Direct output to MATLAB command window in debug mode.
else
    logFile = fopen(logFilePathName, 'a'); % Open or create log file for writing in non-debug mode.
end



end

