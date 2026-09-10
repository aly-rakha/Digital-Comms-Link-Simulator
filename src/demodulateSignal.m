function bits = demodulateSignal(symbols, modulationType)
% demodulateSignal converts received modulation symbols back into bits.
%
% Supported modulation types:
% "BPSK"
% "QPSK"
% "16QAM"
%
% Input:
% symbols        = received/equalized modulation symbols
% modulationType = modulation scheme
%
% Output:
% bits = recovered binary column vector


    %% 1. Prepare inputs

    % Make sure symbols are stored as a column vector
    symbols = symbols(:);

    % Convert modulation name to uppercase MATLAB string
    modulationType = upper(string(modulationType));

    % Allow both "16QAM" and "16-QAM"
    if modulationType == "16-QAM"
        modulationType = "16QAM";
    end


    %% 2. Choose demodulation method

    switch modulationType


        % =====================================================
        % BPSK
        % =====================================================

        case "BPSK"

            % BPSK decision boundary is zero
            %
            % negative -> 0
            % positive -> 1

            bits = double(real(symbols) > 0);


        % =====================================================
        % QPSK
        % =====================================================

        case "QPSK"

            % Real part decides first bit
            bits_I = double(real(symbols) > 0);

            % Imaginary part decides second bit
            bits_Q = double(imag(symbols) > 0);


            % Each QPSK symbol represents:
            %
            % [I bit, Q bit]
            %
            % So rebuild the original sequence:
            %
            % I1 Q1 I2 Q2 I3 Q3 ...

            bits = zeros(2*length(symbols), 1);

            bits(1:2:end) = bits_I;
            bits(2:2:end) = bits_Q;


        % =====================================================
        % 16-QAM
        % =====================================================

        case "16QAM"

            % Undo the sqrt(10) normalization used
            % during modulation

            I = real(symbols) * sqrt(10);
            Q = imag(symbols) * sqrt(10);


            % Each 16-QAM symbol represents 4 bits
            numSymbols = length(symbols);

            bitGroups = zeros(numSymbols, 4);


            % =================================================
            % Decode I axis
            %
            % Gray mapping:
            %
            % amplitude    bits
            %
            %   -3          00
            %   -1          01
            %   +1          11
            %   +3          10
            %
            % Decision boundaries:
            %
            % -2, 0, +2
            % =================================================


            % Region 1:
            % I < -2
            % -> 00

            index = I < -2;

            bitGroups(index,1) = 0;
            bitGroups(index,2) = 0;


            % Region 2:
            % -2 <= I < 0
            % -> 01

            index = I >= -2 & I < 0;

            bitGroups(index,1) = 0;
            bitGroups(index,2) = 1;


            % Region 3:
            % 0 <= I < 2
            % -> 11

            index = I >= 0 & I < 2;

            bitGroups(index,1) = 1;
            bitGroups(index,2) = 1;


            % Region 4:
            % I >= 2
            % -> 10

            index = I >= 2;

            bitGroups(index,1) = 1;
            bitGroups(index,2) = 0;


            % =================================================
            % Decode Q axis
            % =================================================


            % Region 1:
            % Q < -2
            % -> 00

            index = Q < -2;

            bitGroups(index,3) = 0;
            bitGroups(index,4) = 0;


            % Region 2:
            % -2 <= Q < 0
            % -> 01

            index = Q >= -2 & Q < 0;

            bitGroups(index,3) = 0;
            bitGroups(index,4) = 1;


            % Region 3:
            % 0 <= Q < 2
            % -> 11

            index = Q >= 0 & Q < 2;

            bitGroups(index,3) = 1;
            bitGroups(index,4) = 1;


            % Region 4:
            % Q >= 2
            % -> 10

            index = Q >= 2;

            bitGroups(index,3) = 1;
            bitGroups(index,4) = 0;


            % Convert:
            %
            % [b1 b2 b3 b4]
            % [b1 b2 b3 b4]
            % ...
            %
            % back into one long column of bits

            bits = reshape(bitGroups.', [], 1);


        % =====================================================
        % INVALID MODULATION
        % =====================================================

        otherwise

            error( ...
                "Unsupported modulation. Choose BPSK, QPSK, or 16QAM." ...
            );

    end


    %% 3. Make sure output is numeric

    bits = double(bits);

end