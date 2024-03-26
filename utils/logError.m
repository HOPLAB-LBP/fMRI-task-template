function logError(logFile, exception)
% LOGERROR Logs error details to a log file (or to the console) and displays 
% them.
%
%   LOGERROR(logFile, exception) logs the error message and stack trace
%   provided by the input 'exception' to the specified log file. It also
%   displays the error message in the MATLAB Command Window.
%
%   Input Arguments:
%   - logFile:     File handle to the log file where error details will be logged.
%   - exception:   Exception object containing error details, obtained from a
%                  try-catch block.
%
%   Example:
%   logFile = fopen('error_log.txt', 'a');
%   try
%       % code that might generate an error
%   catch exception
%       logError(logFile, exception);
%   end

% Get the full stack trace from the exception object
stackTrace = getReport(exception, 'extended', 'hyperlinks', 'off');

% Log error message and stack trace to the log file
fprintf(logFile, 'ERROR\tErr\t-\t%s\t-\t-\t-\t-\n', string(datetime('now', 'Format', 'yyyy-MM-dd HH:mm:ss.SSS')));
fprintf(logFile, 'Detailed error message:\n%s\n', stackTrace);

% Also display the error message in the MATLAB Command Window
disp(['Error: ' stackTrace]);

end