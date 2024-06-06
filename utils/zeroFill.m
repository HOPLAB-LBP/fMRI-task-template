function zeroFilledStr = zeroFill(input, len)
% ZEROFILL Zero-fills a number or character to a specified length.
%
%   zeroFilledStr = ZEROFILL(input, len) takes a number or character as 
%   input and returns a string of the specified length with leading zeros 
%   added if necessary.
%
%   Inputs:
%     - input: A number or character that needs to be zero-filled.
%     - len: The desired length of the output string.
%
%   Output:
%     - zeroFilledStr: A string of length 'len' with leading zeros added 
%           if the length of 'input' is less than 'len'.
%
%   Example:
%     % Zero-fill the number 4 to a length of 2
%     output1 = zeroFill(4, 2);  % Output: '04'
%
%     % Zero-fill the number 1 to a length of 1
%     output2 = zeroFill(1, 1);  % Output: '1'
%
%     % Zero-fill the number 32 to a length of 5
%     output3 = zeroFill(32, 5); % Output: '00032'
%
%   Author
%   Tim Maniquet [06/06/2024]

    % Convert the input to a string
    str = num2str(input);

    % Calculate the number of zeros needed
    numZeros = len - length(str);

    % If the number of zeros needed is positive, prepend zeros
    if numZeros > 0
        zeroFilledStr = [repmat('0', 1, numZeros) str];
    else
        zeroFilledStr = str;
    end
end
