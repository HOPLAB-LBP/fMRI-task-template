function params = parsetxt(filePath)
    % Read the content of the file
    fileID = fopen(filePath, 'r');
    fileContent = textscan(fileID, '%s', 'Delimiter', '\n');
    fileContent = fileContent{1};
    fclose(fileID);

    % Initialize a structure to store parsed variables
    params = struct();

    % Parse each line of the file
    for i = 1:length(fileContent)
        line = fileContent{i};

        % Ignore lines starting with '%'
        if ~startsWith(line, '%') && ~isempty(line)
            % Split the line into variable name and value
            [varName, varValue] = strtok(line, '=');
            varName = strtrim(varName);
            varValue = strtrim(varValue(2:end)); % Remove the '=' sign

            % Check if the value is numeric
            if ~isnan(str2double(varValue))
                params.(varName) = str2double(varValue);
            else
                % Check if the value is a string
                if (varValue(1) == '"' && varValue(end) == '"') || ...
                   (varValue(1) == "'" && varValue(end) == "'")
                    params.(varName) = varValue(2:end-1);
                else
                    % Check if the value is an array
                    if startsWith(varValue, '[') && endsWith(varValue, ']')
                        varValue = varValue(2:end-1); % Remove brackets
                        % Split the array elements
                        elements = split(varValue, ' ');
                        % Convert numeric elements to numbers
                        numericElements = str2double(elements);
                        % Check if all elements are numeric
                        if ~any(isnan(numericElements))
                            params.(varName) = numericElements;
                        else
                            % Handle cell arrays of strings
                            if startsWith(varValue, '{') && endsWith(varValue, '}')
                                elements = strsplit(varValue(2:end-1), {' ', ',', '\t'}, 'CollapseDelimiters', true);
                                params.(varName) = elements;
                            else
                                % Store the elements as cell array of strings
                                params.(varName) = elements;
                            end
                        end
                    else
                        % It's neither numeric nor a string nor an array, treat as code
                        params.(varName) = varValue;
                    end
                end
            end
        end
    end
end
