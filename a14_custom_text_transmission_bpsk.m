%% a14 - Custom Text Transmission using BPSK over AWGN
% Text -> Bits -> BPSK -> AWGN -> Demodulation -> Text

clear;
close all;
clc;

%% 1. Message and channel setting

message = "Hello from my communication simulator!";

% Higher Eb/N0 means a cleaner channel
EbN0_dB = 6;


%% 2. Convert the text message into bits

% Convert MATLAB string into characters
messageChars = char(message);

% Convert each character into its numerical byte value
messageBytes = uint8(messageChars);

% Convert each byte into 8 binary digits
binaryCharacters = dec2bin(messageBytes, 8);

% Transpose so the bits of each character stay together
binaryCharacters = binaryCharacters.';

% Turn characters '0' and '1' into numeric values 0 and 1
bits = binaryCharacters(:) - '0';

% Total number of transmitted bits
N = length(bits);


%% 3. BPSK modulation

% BPSK mapping:
%
% bit 0 -> -1
% bit 1 -> +1

symbols = 2*bits - 1;


%% 4. AWGN channel

% Convert Eb/N0 from dB into linear scale
EbN0 = 10^(EbN0_dB/10);

% BPSK carries 1 bit per symbol
k = 1;

% Calculate noise standard deviation
noiseSigma = sqrt(1/(2*k*EbN0));

% Generate Gaussian noise
noise = noiseSigma * randn(size(symbols));

% Add noise to transmitted BPSK symbols
receivedSymbols = symbols + noise;


%% 5. BPSK demodulation

% Receiver decision:
%
% received value > 0 -> bit 1
% received value < 0 -> bit 0

receivedBits = double(receivedSymbols > 0);


%% 6. Calculate BER

% Count incorrect bits
numErrors = sum(bits ~= receivedBits);

% Bit Error Rate
BER = numErrors / N;


%% 7. Convert received bits back into text

% Put received bits back into groups of 8
receivedBitGroups = reshape(receivedBits, 8, []).';

% Convert numerical 0 and 1 into characters '0' and '1'
receivedBinaryCharacters = char(receivedBitGroups + '0');

% Convert each group of 8 bits back into a decimal byte
recoveredBytes = uint8(bin2dec(receivedBinaryCharacters));

% Convert the byte values back into characters
recoveredMessage = char(recoveredBytes).';


%% 8. Replace non-printable corrupted characters

% If noise creates strange non-printable ASCII values,
% replace them with ? so the output remains readable.

displayMessage = recoveredMessage;

for i = 1:length(displayMessage)

    characterValue = double(displayMessage(i));

    if characterValue < 32 || characterValue > 126
        displayMessage(i) = '?';
    end

end


%% 9. Display transmission results

fprintf("\n");
fprintf("============================================\n");
fprintf("        BPSK TEXT TRANSMISSION RESULT\n");
fprintf("============================================\n\n");

fprintf("Original message:\n");
fprintf("%s\n\n", messageChars);

fprintf("Recovered message:\n");
fprintf("%s\n\n", displayMessage);

fprintf("Modulation: BPSK\n");
fprintf("Channel: AWGN\n");
fprintf("Eb/N0: %.1f dB\n", EbN0_dB);

fprintf("Number of transmitted bits: %d\n", N);
fprintf("Number of bit errors: %d\n", numErrors);
fprintf("BER: %.6f\n", BER);

fprintf("\n============================================\n");


%% 10. Plot transmission results

% Only show the first 80 bits so the graph remains readable
numBitsToPlot = min(80, N);

% Create figure and store its handle
fig = figure;


% ----- Original bits -----

subplot(3,1,1);

stem(bits(1:numBitsToPlot), 'filled');

xlabel("Bit Number");
ylabel("Bit Value");

title("Original Message Bits");

ylim([-0.2 1.2]);

grid on;


% ----- Recovered bits -----

subplot(3,1,2);

stem(receivedBits(1:numBitsToPlot), 'filled');

xlabel("Bit Number");
ylabel("Bit Value");

title("Recovered Message Bits");

ylim([-0.2 1.2]);

grid on;


% ----- Received BPSK symbols -----

subplot(3,1,3);

scatter( ...
    receivedSymbols, ...
    zeros(size(receivedSymbols)), ...
    20, ...
    'filled' ...
);

hold on;

% Decision boundary between bit 0 and bit 1
xline(0, '--', 'Decision Boundary');

hold off;

xlabel("In-Phase");
ylabel("Quadrature");

title("Received BPSK Symbols");

ylim([-1 1]);

grid on;


%% 11. Save figure

% Create figures folder automatically if it does not exist
if ~exist("figures", "dir")
    mkdir("figures");
end

% Make sure MATLAB finishes drawing the figure
drawnow;

% Create full save location
figurePath = fullfile( ...
    pwd, ...
    "figures", ...
    "bpsk_text_transmission_awgn.png" ...
);

% Save as a high-resolution PNG
exportgraphics(fig, figurePath, "Resolution", 300);

fprintf("\nFigure saved to:\n");
fprintf("%s\n", figurePath);