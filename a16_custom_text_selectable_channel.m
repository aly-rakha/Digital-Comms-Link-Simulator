%% a16 - Custom Text Transmission with Selectable Modulation and Channel
%
% Text
% -> Bits
% -> BPSK / QPSK / 16-QAM
% -> AWGN / Rayleigh
% -> Equalization if needed
% -> Demodulation
% -> BER
% -> Recovered Text

clear;
close all;
clc;


%% 1. USER SETTINGS

message = "Hello from my digital communication simulator!";

% -------------------------------------------------------------
% Choose modulation:
%
% "BPSK"
% "QPSK"
% "16QAM"
% -------------------------------------------------------------

modulationType = "16QAM";


% -------------------------------------------------------------
% Choose channel:
%
% "AWGN"
% "Rayleigh"
% -------------------------------------------------------------

channelType = "Rayleigh";


% Channel quality
EbN0_dB = 10;


%% 2. CONVERT TEXT INTO BITS

% Convert MATLAB string into normal characters
messageChars = char(message);

% Convert characters into numerical byte values
messageBytes = uint8(messageChars);

% Convert each byte into 8 binary digits
binaryCharacters = dec2bin(messageBytes, 8);

% Transpose so the bit order remains correct
binaryCharacters = binaryCharacters.';

% Convert characters '0' and '1' into actual numeric bits
bits = binaryCharacters(:) - '0';

% Total number of transmitted bits
N = length(bits);


%% 3. CONVERT Eb/N0 FROM dB TO LINEAR

EbN0 = 10^(EbN0_dB/10);


%% 4. MODULATION

switch modulationType


    % =========================================================
    % BPSK
    % =========================================================

    case "BPSK"

        % BPSK carries 1 bit per symbol
        k = 1;

        % Mapping:
        %
        % 0 -> -1
        % 1 -> +1

        transmittedSymbols = 2*bits - 1;


    % =========================================================
    % QPSK
    % =========================================================

    case "QPSK"

        % QPSK carries 2 bits per symbol
        k = 2;

        % Split alternating bits into I and Q
        bits_I = bits(1:2:end);
        bits_Q = bits(2:2:end);

        % Mapping:
        %
        % 0 -> -1
        % 1 -> +1

        I = 2*bits_I - 1;
        Q = 2*bits_Q - 1;

        % Build complex QPSK symbols
        %
        % sqrt(2) normalizes average symbol energy to 1

        transmittedSymbols = ...
            (I + 1j*Q) / sqrt(2);


    % =========================================================
    % 16-QAM
    % =========================================================

    case "16QAM"

        % 16-QAM carries 4 bits per symbol
        k = 4;

        % Group bits into groups of four
        bitGroups = reshape(bits, 4, []).';

        % First two bits control I
        bits_I = bitGroups(:,1:2);

        % Last two bits control Q
        bits_Q = bitGroups(:,3:4);

        % Create space for I and Q levels
        I = zeros(size(bits_I,1),1);
        Q = zeros(size(bits_Q,1),1);


        % -----------------------------------------------------
        % I AXIS GRAY MAPPING
        %
        % 00 -> -3
        % 01 -> -1
        % 11 -> +1
        % 10 -> +3
        % -----------------------------------------------------

        idx = bits_I(:,1) == 0 & bits_I(:,2) == 0;
        I(idx) = -3;

        idx = bits_I(:,1) == 0 & bits_I(:,2) == 1;
        I(idx) = -1;

        idx = bits_I(:,1) == 1 & bits_I(:,2) == 1;
        I(idx) = 1;

        idx = bits_I(:,1) == 1 & bits_I(:,2) == 0;
        I(idx) = 3;


        % -----------------------------------------------------
        % Q AXIS GRAY MAPPING
        % -----------------------------------------------------

        idx = bits_Q(:,1) == 0 & bits_Q(:,2) == 0;
        Q(idx) = -3;

        idx = bits_Q(:,1) == 0 & bits_Q(:,2) == 1;
        Q(idx) = -1;

        idx = bits_Q(:,1) == 1 & bits_Q(:,2) == 1;
        Q(idx) = 1;

        idx = bits_Q(:,1) == 1 & bits_Q(:,2) == 0;
        Q(idx) = 3;


        % Create normalized 16-QAM symbols

        transmittedSymbols = ...
            (I + 1j*Q) / sqrt(10);


    otherwise

        error( ...
            "Invalid modulation. Choose BPSK, QPSK, or 16QAM." ...
        );

end


%% 5. CHANNEL

% Noise standard deviation
noiseSigma = sqrt(1/(2*k*EbN0));


switch channelType


    % =========================================================
    % AWGN CHANNEL
    % =========================================================

    case "AWGN"

        if modulationType == "BPSK"

            % BPSK AWGN signal is real
            noise = noiseSigma * ...
                randn(size(transmittedSymbols));

        else

            % QPSK and 16-QAM are complex signals
            noise = noiseSigma * ...
                ( ...
                randn(size(transmittedSymbols)) + ...
                1j*randn(size(transmittedSymbols)) ...
                );

        end


        % AWGN channel:
        %
        % received = transmitted + noise

        receivedSymbols = ...
            transmittedSymbols + noise;


        % No equalization is needed for AWGN

        equalizedSymbols = receivedSymbols;


    % =========================================================
    % RAYLEIGH FADING CHANNEL
    % =========================================================

    case "Rayleigh"

        % Generate Rayleigh fading coefficient
        %
        % h is complex:
        %
        % real part = random Gaussian
        % imaginary part = random Gaussian

        h = ...
            ( ...
            randn(size(transmittedSymbols)) + ...
            1j*randn(size(transmittedSymbols)) ...
            ) / sqrt(2);


        % Rayleigh channel uses complex AWGN

        noise = noiseSigma * ...
            ( ...
            randn(size(transmittedSymbols)) + ...
            1j*randn(size(transmittedSymbols)) ...
            );


        % Rayleigh fading channel:
        %
        % received = h * transmitted + noise

        receivedSymbols = ...
            h .* transmittedSymbols + noise;


        % -----------------------------------------------------
        % CHANNEL EQUALIZATION
        %
        % We assume the receiver knows h perfectly.
        %
        % Divide by h to undo the fading effect.
        % -----------------------------------------------------

        equalizedSymbols = ...
            receivedSymbols ./ h;


    otherwise

        error( ...
            "Invalid channel. Choose AWGN or Rayleigh." ...
        );

end


%% 6. DEMODULATION

switch modulationType


    % =========================================================
    % BPSK DEMODULATION
    % =========================================================

    case "BPSK"

        % Decision boundary = 0
        %
        % positive -> 1
        % negative -> 0

        receivedBits = ...
            double(real(equalizedSymbols) > 0);


    % =========================================================
    % QPSK DEMODULATION
    % =========================================================

    case "QPSK"

        % Real part decides I bit
        receivedBits_I = ...
            double(real(equalizedSymbols) > 0);

        % Imaginary part decides Q bit
        receivedBits_Q = ...
            double(imag(equalizedSymbols) > 0);


        % Rebuild original bit sequence

        receivedBits = zeros(N,1);

        receivedBits(1:2:end) = ...
            receivedBits_I;

        receivedBits(2:2:end) = ...
            receivedBits_Q;


    % =========================================================
    % 16-QAM DEMODULATION
    % =========================================================

    case "16QAM"

        % Undo constellation normalization

        received_I = ...
            real(equalizedSymbols) * sqrt(10);

        received_Q = ...
            imag(equalizedSymbols) * sqrt(10);


        numSymbols = length(equalizedSymbols);

        receivedBitGroups = ...
            zeros(numSymbols,4);


        % -----------------------------------------------------
        % I AXIS DECISIONS
        %
        % Decision boundaries:
        %
        % -2
        %  0
        % +2
        % -----------------------------------------------------


        % Region 1:
        % value < -2
        % -> 00

        idx = received_I < -2;

        receivedBitGroups(idx,1) = 0;
        receivedBitGroups(idx,2) = 0;


        % Region 2:
        % -2 <= value < 0
        % -> 01

        idx = ...
            received_I >= -2 & ...
            received_I < 0;

        receivedBitGroups(idx,1) = 0;
        receivedBitGroups(idx,2) = 1;


        % Region 3:
        % 0 <= value < 2
        % -> 11

        idx = ...
            received_I >= 0 & ...
            received_I < 2;

        receivedBitGroups(idx,1) = 1;
        receivedBitGroups(idx,2) = 1;


        % Region 4:
        % value >= 2
        % -> 10

        idx = received_I >= 2;

        receivedBitGroups(idx,1) = 1;
        receivedBitGroups(idx,2) = 0;


        % -----------------------------------------------------
        % Q AXIS DECISIONS
        % -----------------------------------------------------


        % Region 1 -> 00

        idx = received_Q < -2;

        receivedBitGroups(idx,3) = 0;
        receivedBitGroups(idx,4) = 0;


        % Region 2 -> 01

        idx = ...
            received_Q >= -2 & ...
            received_Q < 0;

        receivedBitGroups(idx,3) = 0;
        receivedBitGroups(idx,4) = 1;


        % Region 3 -> 11

        idx = ...
            received_Q >= 0 & ...
            received_Q < 2;

        receivedBitGroups(idx,3) = 1;
        receivedBitGroups(idx,4) = 1;


        % Region 4 -> 10

        idx = received_Q >= 2;

        receivedBitGroups(idx,3) = 1;
        receivedBitGroups(idx,4) = 0;


        % Convert groups back into one long bit vector

        receivedBits = ...
            reshape(receivedBitGroups.', [], 1);

end


%% 7. CALCULATE BER

% Count incorrect bits

numErrors = ...
    sum(bits ~= receivedBits);


% Calculate Bit Error Rate

BER = ...
    numErrors / N;


%% 8. CONVERT RECEIVED BITS BACK INTO TEXT

% Group recovered bits back into groups of 8

receivedBitGroupsText = ...
    reshape(receivedBits, 8, []).';


% Convert numbers 0 and 1 into characters '0' and '1'

receivedBinaryCharacters = ...
    char(receivedBitGroupsText + '0');


% Convert binary groups into byte values

recoveredBytes = ...
    uint8(bin2dec(receivedBinaryCharacters));


% Convert bytes back into characters

recoveredMessage = ...
    char(recoveredBytes).';


%% 9. REPLACE NON-PRINTABLE CHARACTERS

displayMessage = recoveredMessage;


for i = 1:length(displayMessage)

    characterValue = ...
        double(displayMessage(i));


    if characterValue < 32 || ...
       characterValue > 126

        displayMessage(i) = '?';

    end

end


%% 10. DISPLAY RESULTS

fprintf("\n");

fprintf("=================================================\n");
fprintf("      DIGITAL COMMUNICATION LINK SIMULATOR\n");
fprintf("=================================================\n\n");


fprintf("Original message:\n");
fprintf("%s\n\n", messageChars);


fprintf("Recovered message:\n");
fprintf("%s\n\n", displayMessage);


fprintf("Modulation: %s\n", ...
    modulationType);

fprintf("Channel: %s\n", ...
    channelType);

fprintf("Eb/N0: %.1f dB\n", ...
    EbN0_dB);

fprintf("Bits per symbol: %d\n", ...
    k);

fprintf("Number of transmitted bits: %d\n", ...
    N);

fprintf("Number of transmitted symbols: %d\n", ...
    length(transmittedSymbols));

fprintf("Number of bit errors: %d\n", ...
    numErrors);

fprintf("BER: %.6f\n", ...
    BER);


fprintf("\n=================================================\n");


%% 11. PLOT RESULTS

numBitsToPlot = min(80,N);

fig = figure;


% =============================================================
% ORIGINAL BITS
% =============================================================

subplot(3,1,1);

stem( ...
    bits(1:numBitsToPlot), ...
    'filled' ...
);

xlabel("Bit Number");
ylabel("Bit Value");

title("Original Message Bits");

ylim([-0.2 1.2]);

grid on;


% =============================================================
% RECOVERED BITS
% =============================================================

subplot(3,1,2);

stem( ...
    receivedBits(1:numBitsToPlot), ...
    'filled' ...
);

xlabel("Bit Number");
ylabel("Bit Value");

title("Recovered Message Bits");

ylim([-0.2 1.2]);

grid on;


% =============================================================
% RECEIVED / EQUALIZED CONSTELLATION
% =============================================================

subplot(3,1,3);

scatter( ...
    real(equalizedSymbols), ...
    imag(equalizedSymbols), ...
    20, ...
    'filled' ...
);

hold on;


% -------------------------------------------------------------
% Decision boundaries
% -------------------------------------------------------------

switch modulationType


    case "BPSK"

        xline(0, '--');


    case "QPSK"

        xline(0, '--');
        yline(0, '--');


    case "16QAM"

        boundary = 2/sqrt(10);

        xline(-boundary, '--');
        xline(0, '--');
        xline(boundary, '--');

        yline(-boundary, '--');
        yline(0, '--');
        yline(boundary, '--');

end


hold off;


xlabel("In-Phase");
ylabel("Quadrature");


if channelType == "Rayleigh"

    title( ...
        "Equalized " + ...
        modulationType + ...
        " Constellation - Rayleigh" ...
    );

else

    title( ...
        "Received " + ...
        modulationType + ...
        " Constellation - AWGN" ...
    );

end


axis equal;

grid on;


%% 12. SAVE FIGURE

if ~exist("figures", "dir")

    mkdir("figures");

end


drawnow;


figureName = ...
    "text_transmission_" + ...
    lower(modulationType) + ...
    "_" + ...
    lower(channelType) + ...
    ".png";


figurePath = fullfile( ...
    pwd, ...
    "figures", ...
    figureName ...
);


exportgraphics( ...
    fig, ...
    figurePath, ...
    "Resolution", ...
    300 ...
);


fprintf("\nFigure saved to:\n");

fprintf("%s\n", ...
    figurePath);