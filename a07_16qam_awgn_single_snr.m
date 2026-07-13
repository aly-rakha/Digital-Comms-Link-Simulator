%% a07 - 16-QAM over AWGN at One Eb/N0 Value
% This script simulates 16-QAM modulation over an AWGN channel
% at one Eb/N0 value and plots the noisy 16-QAM constellation.
%
% 16-QAM uses 4 bits per symbol.

clear; close all; clc;

%% 1. Generate random bits

N = 10000;                  % Number of bits to transmit

% 16-QAM uses 4 bits per symbol, so N must be divisible by 4
if mod(N, 4) ~= 0
    error("N must be divisible by 4 for 16-QAM.");
end

bits = randi([0 1], N, 1);  % Generate random 0s and 1s

%% 2. Group bits into symbols

% Each 16-QAM symbol uses 4 bits:
% bits 1 and 2 control the In-phase axis
% bits 3 and 4 control the Quadrature axis

bitGroups = reshape(bits, 4, []).';

bits_I = bitGroups(:, 1:2);   % First two bits control I axis
bits_Q = bitGroups(:, 3:4);   % Last two bits control Q axis

numSymbols = size(bitGroups, 1);

%% 3. 16-QAM modulation

% We use Gray-coded 4-PAM mapping on each axis:
%
% 00 -> -3
% 01 -> -1
% 11 -> +1
% 10 -> +3
%
% The I axis uses 2 bits.
% The Q axis uses 2 bits.
% Together, they create 4 x 4 = 16 points.

I = zeros(numSymbols, 1);
Q = zeros(numSymbols, 1);

% In-phase mapping
idx = bits_I(:,1) == 0 & bits_I(:,2) == 0;
I(idx) = -3;

idx = bits_I(:,1) == 0 & bits_I(:,2) == 1;
I(idx) = -1;

idx = bits_I(:,1) == 1 & bits_I(:,2) == 1;
I(idx) = 1;

idx = bits_I(:,1) == 1 & bits_I(:,2) == 0;
I(idx) = 3;

% Quadrature mapping
idx = bits_Q(:,1) == 0 & bits_Q(:,2) == 0;
Q(idx) = -3;

idx = bits_Q(:,1) == 0 & bits_Q(:,2) == 1;
Q(idx) = -1;

idx = bits_Q(:,1) == 1 & bits_Q(:,2) == 1;
Q(idx) = 1;

idx = bits_Q(:,1) == 1 & bits_Q(:,2) == 0;
Q(idx) = 3;

% Create complex 16-QAM symbols
% Divide by sqrt(10) to normalize average symbol energy to 1

symbols = (I + 1j*Q) / sqrt(10);

%% 4. Add AWGN noise

EbN0_dB = 10;                  % Eb/N0 value in dB
EbN0 = 10^(EbN0_dB/10);        % Convert dB to linear scale

k = 4;                         % 16-QAM carries 4 bits per symbol

% Complex AWGN noise for 16-QAM
noiseSigma = sqrt(1/(2*k*EbN0));

noise = noiseSigma * (randn(size(symbols)) + 1j*randn(size(symbols)));

receivedSymbols = symbols + noise;

%% 5. 16-QAM demodulation

% Undo normalization for easier decision making
received_I = real(receivedSymbols) * sqrt(10);
received_Q = imag(receivedSymbols) * sqrt(10);

receivedBitGroups = zeros(numSymbols, 4);

% Decision boundaries for levels -3, -1, +1, +3 are:
% -2, 0, +2

% Demodulate I axis
idx = received_I < -2;
receivedBitGroups(idx, 1:2) = repmat([0 0], sum(idx), 1);

idx = received_I >= -2 & received_I < 0;
receivedBitGroups(idx, 1:2) = repmat([0 1], sum(idx), 1);

idx = received_I >= 0 & received_I < 2;
receivedBitGroups(idx, 1:2) = repmat([1 1], sum(idx), 1);

idx = received_I >= 2;
receivedBitGroups(idx, 1:2) = repmat([1 0], sum(idx), 1);

% Demodulate Q axis
idx = received_Q < -2;
receivedBitGroups(idx, 3:4) = repmat([0 0], sum(idx), 1);

idx = received_Q >= -2 & received_Q < 0;
receivedBitGroups(idx, 3:4) = repmat([0 1], sum(idx), 1);

idx = received_Q >= 0 & received_Q < 2;
receivedBitGroups(idx, 3:4) = repmat([1 1], sum(idx), 1);

idx = received_Q >= 2;
receivedBitGroups(idx, 3:4) = repmat([1 0], sum(idx), 1);

% Convert bit groups back into one column vector
receivedBits = reshape(receivedBitGroups.', N, 1);

%% 6. Count errors and calculate BER

numErrors = sum(bits ~= receivedBits);
BER = numErrors / N;

%% 7. Display results

fprintf("Modulation: 16-QAM\n");
fprintf("Eb/N0: %d dB\n", EbN0_dB);
fprintf("Number of transmitted bits: %d\n", N);
fprintf("Number of 16-QAM symbols: %d\n", numSymbols);
fprintf("Number of errors: %d\n", numErrors);
fprintf("BER: %.5f\n", BER);

%% 8. Plot noisy 16-QAM constellation

numConstellationPoints = 1000;

figure;

scatter(real(receivedSymbols(1:numConstellationPoints)), ...
        imag(receivedSymbols(1:numConstellationPoints)), ...
        'filled');

hold on;

% Plot ideal 16-QAM reference points
levels = [-3 -1 1 3] / sqrt(10);
[refI, refQ] = meshgrid(levels, levels);

plot(refI(:), refQ(:), 'kx', 'LineWidth', 2, 'MarkerSize', 10);

% Decision boundaries after normalization
xline(-2/sqrt(10), '--');
xline(0, '--');
xline(2/sqrt(10), '--');

yline(-2/sqrt(10), '--');
yline(0, '--');
yline(2/sqrt(10), '--');

xlabel("In-phase axis");
ylabel("Quadrature axis");
title("16-QAM Constellation with AWGN Noise");
legend("Received Symbols", "Ideal 16-QAM Points");
axis equal;
grid on;

%% 9. Save figure

if ~exist("figures", "dir")
    mkdir("figures");
end

ax = gca;
ax.Toolbar.Visible = 'off';

saveas(gcf, "figures/16qam_awgn_constellation.png");