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
    
    % Check if the value is a string
    if startsWith(param_value, '''') && endsWith(param_value, '''')
        % Remove single quotes
        param_value = strtrim(param_value(2:end-1));
    else
        % Check if the value is a list enclosed in square brackets or curly brackets
        if (startsWith(param_value, '[') && endsWith(param_value, ']')) || ...
           (startsWith(param_value, '{') && endsWith(param_value, '}'))
            % Remove brackets
            param_value = strtrim(param_value(2:end-1));
            % Split the list and handle string elements
            list_values = strsplit(param_value, ',');
            for i = 1:numel(list_values)
                % Remove single quotes if present
                if startsWith(list_values{i}, '''') && endsWith(list_values{i}, '''')
                    list_values{i} = strtrim(list_values{i}(2:end-1));
                end
            end
            % Assign parameter to structure as a cell array
            params.(param_name) = list_values;
            % Continue to the next line
            tline = fgetl(fid);
            continue;
        end
        % Check if the value is numeric
        if ~isnan(str2double(param_value))
            % Convert to number
            param_value = str2double(param_value);
        end
    end
    
    % Assign parameter to structure
    params.(param_name) = param_value;
    
    % Read next line
    tline = fgetl(fid);
end

% Close the file
fclose(fid);

% Display a message
disp(['Parameters imported from "', filename, '".']);

end
