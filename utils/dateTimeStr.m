function dateTimeString = dateTimeStr()
% GETCURRENTDATETIMESTRING Returns the current date and time as a string.
%   The date and time are formatted as 'yyyy-MM-dd HH:mm:ss.SSS'.
%
%   Output:
%       - dateTimeStr: A string representing the current date and time.
%
%   Example:
%       - dateTimeStr = getCurrentDateTimeString();
% 
%   Author
%   Tim Maniquet [27/3/24]

% Extract the current date and time
dateTimeString = char(datetime('now', 'Format', 'yyyy-MM-dd-HH-mm'));


end