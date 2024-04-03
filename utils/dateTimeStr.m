function dateTimeStr = dateTimeStr()
% GETCURRENTDATETIMESTRING Returns the current date and time as a string.
%   The date and time are formatted as 'yyyy-MM-dd HH:mm:ss.SSS'.
%
%   Output:
%       - dateTimeStr: A string representing the current date and time.
%
%   Example:
%       - dateTimeStr = getCurrentDateTimeString();

% Extract the current date and time
dateTimeStr = string(datetime('now', 'Format', 'yyyy-MM-dd HH:mm:ss.SSS'));

% Extract the first (and only) element of the string array
dateTimeStr = dateTimeStr{1};


end