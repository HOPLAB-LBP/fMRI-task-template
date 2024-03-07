function result = create_object(list_length, parameter_value)
    % Create the list
    list = 1:list_length;
    
    % Calculate the number of elements in each section
    section_length = floor(list_length / parameter_value);
    
    % Create the second column
    second_column = repelem(1:parameter_value, section_length);
    
    % Extend the second column to match the list length
    second_column = [second_column, repmat(parameter_value, 1, mod(list_length, parameter_value))];
    
    % Transpose to make it a column vector
    second_column = second_column';
    
    % Create the object
    result = [list', second_column];
end
