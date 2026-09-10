function bits = textToBits(message)
% textToBits converts a text message into a column vector of binary bits.
%
% Example:
% "A" -> 01000001

    % Convert MATLAB string into characters
    messageChars = char(message);

    % Convert characters into byte values
    messageBytes = uint8(messageChars);

    % Convert each byte into 8 binary digits
    binaryCharacters = dec2bin(messageBytes, 8);

    % Transpose so bit order is correct
    binaryCharacters = binaryCharacters.';

    % Convert '0' and '1' characters into numeric 0 and 1
    bits = binaryCharacters(:) - '0';

    % Make sure output is numeric
    bits = double(bits);

end