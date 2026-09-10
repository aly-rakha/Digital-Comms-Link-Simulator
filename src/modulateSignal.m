function [symbols, k] = modulateSignal(bits, modulationType)
% modulateSignal converts binary bits into modulation symbols.
%
% Supported modulation types:
% "BPSK"
% "QPSK"
% "16QAM"
%
% Outputs:
% symbols = transmitted modulation symbols
% k       = number of bits carried by each symbol


    %% 1. Prepare inputs

    % Make sure bits are stored as one column
    bits = double(bits(:));

    % Make sure modulationType is a MATLAB string
    modulationType = upper(string(modulationType));

    % Allow either "16QAM" or "16-QAM"
    if modulationType == "16-QAM"
        modulationType = "16QAM";
    end


    %% 2. Check that the input really contains bits

    if any(bits ~= 0 & bits ~= 1)

        error("Input must contain only binary values 0 and 1.");

    end


    %% 3. Select modulation

    switch modulationType


        % =====================================================
        % BPSK
        % =====================================================

        case "BPSK"

            % BPSK carries 1 bit per symbol
            k = 1;

            % Mapping:
            %
            % 0 -> -1
            % 1 -> +1

            symbols = 2*bits - 1;


        % =====================================================
        % QPSK
        % =====================================================

        case "QPSK"

            % QPSK carries 2 bits per symbol
            k = 2;


            % Number of bits must be divisible by 2

            if mod(length(bits), 2) ~= 0

                error( ...
                    "QPSK requires a number of bits divisible by 2." ...
                );

            end


            % First bit controls I
            bits_I = bits(1:2:end);

            % Second bit controls Q
            bits_Q = bits(2:2:end);


            % Convert:
            %
            % 0 -> -1
            % 1 -> +1

            I = 2*bits_I - 1;

            Q = 2*bits_Q - 1;


            % Create QPSK symbols
            %
            % sqrt(2) makes average symbol energy = 1

            symbols = ...
                (I + 1j*Q) / sqrt(2);


        % =====================================================
        % 16-QAM
        % =====================================================

        case "16QAM"

            % 16-QAM carries 4 bits per symbol
            k = 4;


            % Number of bits must be divisible by 4

            if mod(length(bits), 4) ~= 0

                error( ...
                    "16-QAM requires a number of bits divisible by 4." ...
                );

            end


            % Put bits into groups of four:
            %
            % [b1 b2 b3 b4]
            %
            % b1,b2 -> I
            % b3,b4 -> Q

            bitGroups = ...
                reshape(bits, 4, []).';


            b1 = bitGroups(:,1);
            b2 = bitGroups(:,2);

            b3 = bitGroups(:,3);
            b4 = bitGroups(:,4);


            % -------------------------------------------------
            % Gray-coded amplitude mapping
            %
            % 00 -> -3
            % 01 -> -1
            % 11 -> +1
            % 10 -> +3
            %
            % This formula produces exactly that mapping.
            % -------------------------------------------------

            I = ...
                (2*b1 - 1) .* ...
                (3 - 2*b2);


            Q = ...
                (2*b3 - 1) .* ...
                (3 - 2*b4);


            % Build complex 16-QAM symbols
            %
            % sqrt(10) normalizes average symbol energy to 1

            symbols = ...
                (I + 1j*Q) / sqrt(10);


        % =====================================================
        % INVALID INPUT
        % =====================================================

        otherwise

            error( ...
                "Unsupported modulation. Choose BPSK, QPSK, or 16QAM." ...
            );

    end

end