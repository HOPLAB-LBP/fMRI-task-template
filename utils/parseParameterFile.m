function params = parseParameterFile(filename)

% PARSEPARAMETERFILE Parses a custom text file containing MATLAB parameters.
%   This function reads the specified text file and extracts MATLAB parameters
%   while ignoring commented-out text.
%
%   INPUT:
%   filename: The name of the text file to parse.
%
%   OUTPUT:
%   params: A MATLAB structure containing the extracted parameters.

% Check if the file exists
if exist(filename, 'file') ~= 2
    error(['Your parameter file "', filename, '" does not exist.']);
end

% Read the text file in a file identifier
fid = fopen(filename, 'r');
% Check if the file was found and read
if fid == -1
    error('Could not open file');
end

% Initialize parameters structure
params = struct();

% Read lines from the file
tline = fgetl(fid);
while ischar(tline)
    % Ignore lines that start with '%'
    if isempty(tline) || tline(1) == '%'
        tline = fgetl(fid);
        continue;
    end
    
    % Split the line by '='
    parts = strsplit(tline, '=');
    
    % Extract parameter name and value
    param_name = strtrim(parts{1});
    param_value = strtrim(parts{2});
    
    % Convert value to appropriate type if necessary
    if contains(param_value, 'x')
        % Split dimensions
        dimensions = str2double(strsplit(param_value, 'x'));
        param_value = dimensions;
    elseif isstrprop(param_value(1), 'digit')
        % Convert to number
        param_value = str2double(param_value);
    else
        % Trim leading and trailing whitespace
        param_value = strtrim(param_value);
    end
    
    % Assign parameter to structure
    params.(param_name) = param_value;
    
    % Read next line
    tline = fgetl(fid);
end

% Close the file
fclose(fid);

% Give a 
disp(['Parameters imported from "', filename, '".']);


end

