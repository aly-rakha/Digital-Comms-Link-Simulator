function [BER, numErrors] = calculateBER(originalBits, receivedBits)
% calculateBER compares transmitted and received bits.
%
% Inputs:
% originalBits = transmitted bit sequence
% receivedBits = recovered bit sequence
%
% Outputs:
% BER       = Bit Error Rate
% numErrors = total number of incorrect bits


    %% 1. Make both inputs column vectors

    originalBits = originalBits(:);
    receivedBits = receivedBits(:);


    %% 2. Check that both vectors have the same length

    if length(originalBits) ~= length(receivedBits)

        error("Original and received bit vectors must have the same length.");

    end


    %% 3. Count the number of incorrect bits

    numErrors = sum(originalBits ~= receivedBits);


    %% 4. Calculate Bit Error Rate

    BER = numErrors / length(originalBits);

end