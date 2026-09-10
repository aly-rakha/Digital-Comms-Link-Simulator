function message = bitsToText(bits)
% bitsToText converts a binary bit vector back into text.
%
% Example:
% 01000001 -> "A"

    % Make sure bits are stored as one column
    bits = bits(:);

    % Every character must contain exactly 8 bits
    if mod(length(bits), 8) ~= 0
        error("Number of bits must be divisible by 8.");
    end

    % Put the bits into groups of 8
    bitGroups = reshape(bits, 8, []).';

    % Convert numeric 0 and 1 into characters '0' and '1'
    binaryCharacters = char(bitGroups + '0');

    % Convert each 8-bit binary number into a decimal byte value
    byteValues = uint8(bin2dec(binaryCharacters));

    % Convert byte values back into characters
    message = char(byteValues).';

end