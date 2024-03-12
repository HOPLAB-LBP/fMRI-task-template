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

% Initialize an empty parameters structure
params = struct();

% Read lines from the file
tline = fgetl(fid);

% Extract the information from the line
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
    
    % Check for the type of the value and save it accordingly
    
    % Check if the value is a string (single or double quote)
    if startsWith(param_value, '''') || startsWith(param_value, '"') ...
            && endsWith(param_value, '''') || endsWith(param_value, '"')
        % Remove single quotes and assign the value
        param_value = strtrim(param_value(2:end-1));
    
    % Check if the value is a boolean
    elseif param_value == "true"
        param_value = true;
    elseif param_value == "false"
        param_value = false;
    
    % Check if the value is an array of numbers
    elseif (startsWith(param_value, '[') && endsWith(param_value, ']'))
        % Remove brackets
        param_value = strtrim(param_value(2:end-1));
        % Split the list and handle string elements
        list_values = strsplit(param_value, ' ');
        % Create an empty array to store the values
        array = zeros(1, length(list_values));
        % Loop through the values of the list
        for i = 1:numel(list_values)
            % Add the elements in the array as numbers
            array(i) = str2double(list_values{i});
        end
        % Save the resulting array in the parameter value
        param_value = array;

    % Check if the value is a list of strings
    elseif (startsWith(param_value, '{') && endsWith(param_value, '}'))
        % Remove curly brackets
        param_value = strtrim(param_value(2:end-1));
        % Split the list and handle string elements
        list_values = strsplit(param_value, ' ');
        % Create an empty array to store the values
        string_list = cell(1, length(list_values));
        % Loop through the values of the list
        for i = 1:numel(list_values)
            % Remove unneccessary quotation marks
            list_values{i} = strrep(list_values{i}, '"', '');
            list_values{i} = strrep(list_values{i}, '''', '');
            % Add the elements in the array as numbers
            string_list{i} = list_values{i};
        end
        % Save the resulting array in the parameter value
        param_value = string_list;

    % Check if the value is numeric
    elseif ~isnan(str2double(param_value))
        % Convert to number
        param_value = str2double(param_value);

    end
    
    % Assign parameter to structure
    params.(param_name) = param_value;
    
    % Read next line and continue in the while loop
    tline = fgetl(fid);

end

% When done, close the file
fclose(fid);

% Display a message
disp(['Parameters imported from "', filename, '".']);

end
