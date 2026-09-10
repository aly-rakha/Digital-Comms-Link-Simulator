%% a15 - Custom Text Transmission with Selectable Modulation
% Text -> Bits -> BPSK/QPSK/16-QAM -> AWGN
% -> Demodulation -> BER -> Recovered Text

clear;
close all;
clc;


%% 1. USER SETTINGS

message = "Hello from my digital communication simulator!";

% Choose:
% "BPSK"
% "QPSK"
% "16QAM"

modulationType = "16QAM";

% Channel quality
EbN0_dB = 10;


%% 2. CONVERT TEXT INTO BITS

% Convert MATLAB string to characters
messageChars = char(message);

% Convert characters to byte values
messageBytes = uint8(messageChars);

% Convert every byte into 8 binary digits
binaryCharacters = dec2bin(messageBytes, 8);

% Transpose so the bits remain in correct order
binaryCharacters = binaryCharacters.';

% Convert characters '0' and '1' into numeric 0 and 1
bits = binaryCharacters(:) - '0';

% Number of transmitted bits
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
        % 0 -> -1
        % 1 -> +1

        transmittedSymbols = 2*bits - 1;


    % =========================================================
    % QPSK
    % =========================================================

    case "QPSK"

        % QPSK carries 2 bits per symbol
        k = 2;

        % Split bits into I and Q bits
        bits_I = bits(1:2:end);
        bits_Q = bits(2:2:end);

        % Map:
        % 0 -> -1
        % 1 -> +1

        I = 2*bits_I - 1;
        Q = 2*bits_Q - 1;

        % Build complex QPSK symbols
        %
        % sqrt(2) normalizes average symbol energy to 1

        transmittedSymbols = (I + 1j*Q) / sqrt(2);


    % =========================================================
    % 16-QAM
    % =========================================================

    case "16QAM"

        % 16-QAM carries 4 bits per symbol
        k = 4;

        % Put bits into groups of 4
        bitGroups = reshape(bits, 4, []).';

        % First two bits control I
        bits_I = bitGroups(:,1:2);

        % Last two bits control Q
        bits_Q = bitGroups(:,3:4);

        % Allocate space
        I = zeros(size(bits_I,1),1);
        Q = zeros(size(bits_Q,1),1);


        % -----------------------------------------------------
        % Gray-coded I mapping
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
        % Gray-coded Q mapping
        % -----------------------------------------------------

        idx = bits_Q(:,1) == 0 & bits_Q(:,2) == 0;
        Q(idx) = -3;

        idx = bits_Q(:,1) == 0 & bits_Q(:,2) == 1;
        Q(idx) = -1;

        idx = bits_Q(:,1) == 1 & bits_Q(:,2) == 1;
        Q(idx) = 1;

        idx = bits_Q(:,1) == 1 & bits_Q(:,2) == 0;
        Q(idx) = 3;


        % Create 16-QAM symbols
        %
        % sqrt(10) normalizes average symbol energy to 1

        transmittedSymbols = (I + 1j*Q) / sqrt(10);


    otherwise

        error("Invalid modulation type. Choose BPSK, QPSK, or 16QAM.");

end


%% 5. AWGN CHANNEL

% Noise standard deviation
%
% k = bits per symbol
%
% BPSK  -> k = 1
% QPSK  -> k = 2
% 16QAM -> k = 4

noiseSigma = sqrt(1/(2*k*EbN0));


% BPSK uses a real signal
if modulationType == "BPSK"

    noise = noiseSigma * randn(size(transmittedSymbols));

else

    % QPSK and 16-QAM use complex signals
    noise = noiseSigma * ...
        (randn(size(transmittedSymbols)) + ...
         1j*randn(size(transmittedSymbols)));

end


% Add noise
receivedSymbols = transmittedSymbols + noise;


%% 6. DEMODULATION

switch modulationType


    % =========================================================
    % BPSK DEMODULATION
    % =========================================================

    case "BPSK"

        % Positive -> bit 1
        % Negative -> bit 0

        receivedBits = double(real(receivedSymbols) > 0);


    % =========================================================
    % QPSK DEMODULATION
    % =========================================================

    case "QPSK"

        % Real part decides I bit
        receivedBits_I = double(real(receivedSymbols) > 0);

        % Imaginary part decides Q bit
        receivedBits_Q = double(imag(receivedSymbols) > 0);


        % Rebuild original bit order
        receivedBits = zeros(N,1);

        receivedBits(1:2:end) = receivedBits_I;
        receivedBits(2:2:end) = receivedBits_Q;


    % =========================================================
    % 16-QAM DEMODULATION
    % =========================================================

    case "16QAM"

        % Undo normalization
        received_I = real(receivedSymbols) * sqrt(10);
        received_Q = imag(receivedSymbols) * sqrt(10);

        numSymbols = length(receivedSymbols);

        receivedBitGroups = zeros(numSymbols,4);


        % -----------------------------------------------------
        % Decode I axis
        %
        % boundaries:
        % -2, 0, +2
        % -----------------------------------------------------

        idx = received_I < -2;

        receivedBitGroups(idx,1) = 0;
        receivedBitGroups(idx,2) = 0;


        idx = received_I >= -2 & received_I < 0;

        receivedBitGroups(idx,1) = 0;
        receivedBitGroups(idx,2) = 1;


        idx = received_I >= 0 & received_I < 2;

        receivedBitGroups(idx,1) = 1;
        receivedBitGroups(idx,2) = 1;


        idx = received_I >= 2;

        receivedBitGroups(idx,1) = 1;
        receivedBitGroups(idx,2) = 0;


        % -----------------------------------------------------
        % Decode Q axis
        % -----------------------------------------------------

        idx = received_Q < -2;

        receivedBitGroups(idx,3) = 0;
        receivedBitGroups(idx,4) = 0;


        idx = received_Q >= -2 & received_Q < 0;

        receivedBitGroups(idx,3) = 0;
        receivedBitGroups(idx,4) = 1;


        idx = received_Q >= 0 & received_Q < 2;

        receivedBitGroups(idx,3) = 1;
        receivedBitGroups(idx,4) = 1;


        idx = received_Q >= 2;

        receivedBitGroups(idx,3) = 1;
        receivedBitGroups(idx,4) = 0;


        % Convert groups back into one long bit vector
        receivedBits = reshape(receivedBitGroups.', [], 1);

end


%% 7. CALCULATE BER

numErrors = sum(bits ~= receivedBits);

BER = numErrors / N;


%% 8. CONVERT RECEIVED BITS BACK INTO TEXT

% Put bits back into groups of 8
receivedBitGroupsText = reshape(receivedBits, 8, []).';

% Convert numeric bits to characters
receivedBinaryCharacters = ...
    char(receivedBitGroupsText + '0');

% Convert binary numbers back to byte values
recoveredBytes = ...
    uint8(bin2dec(receivedBinaryCharacters));

% Convert bytes back into characters
recoveredMessage = char(recoveredBytes).';


%% 9. REPLACE NON-PRINTABLE CHARACTERS

displayMessage = recoveredMessage;

for i = 1:length(displayMessage)

    characterValue = double(displayMessage(i));

    if characterValue < 32 || characterValue > 126

        displayMessage(i) = '?';

    end

end


%% 10. DISPLAY RESULTS

fprintf("\n");

fprintf("=================================================\n");
fprintf("       CUSTOM TEXT TRANSMISSION SIMULATOR\n");
fprintf("=================================================\n\n");

fprintf("Original message:\n");
fprintf("%s\n\n", messageChars);

fprintf("Recovered message:\n");
fprintf("%s\n\n", displayMessage);

fprintf("Modulation: %s\n", modulationType);

fprintf("Channel: AWGN\n");

fprintf("Eb/N0: %.1f dB\n", EbN0_dB);

fprintf("Bits per symbol: %d\n", k);

fprintf("Number of transmitted bits: %d\n", N);

fprintf("Number of transmitted symbols: %d\n", ...
    length(transmittedSymbols));

fprintf("Number of bit errors: %d\n", numErrors);

fprintf("BER: %.6f\n", BER);

fprintf("\n=================================================\n");


%% 11. PLOT RESULTS

numBitsToPlot = min(80,N);

fig = figure;


% =============================================================
% ORIGINAL BITS
% =============================================================

subplot(3,1,1);

stem(bits(1:numBitsToPlot), 'filled');

xlabel("Bit Number");
ylabel("Bit Value");

title("Original Message Bits");

ylim([-0.2 1.2]);

grid on;


% =============================================================
% RECEIVED BITS
% =============================================================

subplot(3,1,2);

stem(receivedBits(1:numBitsToPlot), 'filled');

xlabel("Bit Number");
ylabel("Bit Value");

title("Recovered Message Bits");

ylim([-0.2 1.2]);

grid on;


% =============================================================
% CONSTELLATION
% =============================================================

subplot(3,1,3);

scatter( ...
    real(receivedSymbols), ...
    imag(receivedSymbols), ...
    20, ...
    'filled' ...
);

hold on;


% Add correct decision boundaries depending on modulation

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

title("Received " + modulationType + " Constellation");

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
    "_awgn.png";


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

fprintf("%s\n", figurePath);