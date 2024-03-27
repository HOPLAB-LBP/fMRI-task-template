function dateTimeStr = dateTimeStr()
% getCurrentDateTimeString returns the current date and time as a string
% in the format 'yyyy-MM-dd HH:mm:ss.SSS'.
%
% OUTPUT:
% - dateTimeStr: A string representing the current date and time.
%
% Example:
%   dateTimeStr = getCurrentDateTimeString();

dateTimeStr = string(datetime('now', 'Format', 'yyyy-MM-dd HH:mm:ss.SSS'));

end