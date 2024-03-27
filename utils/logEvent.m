function logEvent(logFile, eventType, eventName, dateTime, expOnset, actualOnset, delta, eventID)

% Create the log message line from the input
logMessage = sprintf('\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n', ...
                    string(eventType), string(eventName), string(dateTime), ...
                    string(expOnset), string(actualOnset), string(delta), ...
                    string(eventID));

% If the log file is not the command window
if ~(logFile == 1)
    % Log in the external log file
    fprintf(logFile, logMessage);
end

% In both cases, log in the command window
fprintf(1, logMessage);

end