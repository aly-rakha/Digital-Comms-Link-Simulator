%% 01 - BPSK over AWGN at One Eb/N0 Value
% This script simulates a simple digital communication link:
%
% bits -> BPSK symbols -> noisy channel -> received bits -> BER

clear; close all; clc;

%% 1. Generate random bits

N = 10000;                  % Number of bits to transmit
bits = randi([0 1], N, 1);  % Generate random 0s and 1s

%% 2. BPSK modulation

% BPSK mapping:
% bit 0 -> symbol -1
% bit 1 -> symbol +1

symbols = 2*bits - 1;

%% 3. Add AWGN noise

% Eb/N0 controls how strong the signal is compared to the noise.
% Higher Eb/N0 = less noise.
% Lower Eb/N0 = more noise.

EbN0_dB = 2;                % Eb/N0 value in dB
EbN0 = 10^(EbN0_dB/10);     % Convert dB value to normal linear value

% For BPSK, this formula gives the standard deviation of the noise
noiseSigma = sqrt(1/(2*EbN0));

% randn() creates random Gaussian noise
noise = noiseSigma * randn(size(symbols));

% Received signal = transmitted signal + noise
receivedSymbols = symbols + noise;

%% 4. BPSK demodulation

% Receiver decision rule:
% if received symbol > 0, decide bit 1
% if received symbol < 0, decide bit 0

receivedBits = double(receivedSymbols > 0);

%% 5. Count errors and calculate BER

numErrors = sum(bits ~= receivedBits);
BER = numErrors / N;

%% 6. Display results

fprintf("Eb/N0: %d dB\n", EbN0_dB);
fprintf("Number of transmitted bits: %d\n", N);
fprintf("Number of errors: %d\n", numErrors);
fprintf("BER: %.5f\n", BER);

%% 7. Plot results

numToPlot = 30;                  % Only plot first 30 bits/symbols
numConstellationPoints = 500;    % Only plot first 500 received symbols

figure;

% Plot original bits
subplot(3,1,1);
stem(bits(1:numToPlot), 'filled');
ylim([-0.2 1.2]);
xlabel("Bit index");
ylabel("Bit value");
title("Original Transmitted Bits");
grid on;

% Plot clean BPSK symbols
subplot(3,1,2);
stem(symbols(1:numToPlot), 'filled');
ylim([-1.5 1.5]);
xlabel("Symbol index");
ylabel("BPSK symbol");
title("Clean BPSK Modulated Symbols");
grid on;

% Plot noisy received BPSK constellation
subplot(3,1,3);
scatter(receivedSymbols(1:numConstellationPoints), ...
        zeros(numConstellationPoints, 1), ...
        'filled');

xlabel("In-phase axis");
ylabel("Quadrature axis");
title("Noisy BPSK Constellation");
ylim([-1 1]);
grid on;