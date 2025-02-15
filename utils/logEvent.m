function logEvent(logFile, eventType, eventName, dateTime, expOnset, actualOnset, delta, eventID)
% LOGEVENT Logs an event to the command window and/or to a file.
%
%   This function logs an event to a specified log file and/or the command window.
%   The event is represented by various parameters such as event type, name, date and time, etc.
%
%   Input arguments:
%       - logFile: The file identifier of the log file. Specify 1 to log to the command window only.
%       - eventType: The type of the event (e.g., 'Error', 'Warning', 'Info').
%       - eventName: The name or description of the event.
%       - dateTime: The date and time of the event. Should be provided as a string in the format 'yyyy-MM-dd HH:mm:ss.SSS'.
%       - expOnset: The expected onset time of the event.
%       - actualOnset: The actual onset time of the event.
%       - delta: The difference between the expected and actual onset times.
%       - eventID: An identifier or code for the event.
%
%   Output:
%       None. The function logs the event message to the specified file and/or the command window.
%
%   Example:
%       logEvent(logFile, 'Error', 'File not found', '2024-03-27
%       09:15:23.123', '09:15:00.000', '09:15:23.100', '00:00:23.100', 'E001');
%
%   Note:
%       - If logFile is 1, the event is logged only to the command window.
%       - The date and time (dateTime) should be provided as a string in 
%           the format 'yyyy-MM-dd HH:mm:ss.SSS'.
%       - The utility function formatVariable ensures the input fields can
%           be given in any format and still get logged properly.
% 
%   Author
%   Tim Maniquet [27/3/24]

% Helper function to determine the correct format for each input
function format = formatVariable(var)
    if ischar(var) || isstring(var)
        format = '%s';
    elseif isnumeric(var)
        format = '%f';
    else
        error('Unsupported variable type: %s', class(var));
    end
end

% Dynamically generate the format specifier
formatSpec = sprintf('%s\t%s\t%s\t%s\t%s\t%s\t%s\n', ...
                     formatVariable(eventType), ...
                     formatVariable(eventName), ...
                     formatVariable(dateTime), ...
                     formatVariable(expOnset), ...
                     formatVariable(actualOnset), ...
                     formatVariable(delta), ...
                     formatVariable(eventID));

% Create the log message line from the input using the specified format
logMessage = sprintf(formatSpec, ...
                    string(eventType), string(eventName), string(dateTime), ...
                    expOnset, actualOnset, delta, ...
                    string(eventID));

% If the log file is not the command window
if ~(logFile == 1)
    % Log in the external log file
    fprintf(logFile, logMessage);
end

% In both cases, log in the command window
fprintf(1, logMessage);

end